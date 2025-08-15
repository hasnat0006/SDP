import 'package:flutter/material.dart';

import 'pending_req.dart';  // Import your PendingRequestsPage here
import 'backend.dart';

class ManageAppointments extends StatefulWidget {
  final String? doctorId;
  final String? userType; // Add user type to determine doctor vs patient
  
  const ManageAppointments({Key? key, this.doctorId, this.userType}) : super(key: key);

  @override
  State<ManageAppointments> createState() => _ManageAppointmentsState();
}

class _ManageAppointmentsState extends State<ManageAppointments> {
  bool acceptingAppointments = true;
  List<Appointment> appointments = [];
  List<bool> reminders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      print('🔄 Fetching appointments...');
      
      List<Appointment> fetched;
      
      // Check if user is doctor or patient
      if (widget.userType == 'doctor') {
        // For doctors, fetch appointments where they are the doctor
        fetched = await AppointmentService.fetchConfirmedAppointmentsForDoctor(widget.doctorId);
      } else {
        // For patients, fetch appointments where they are the patient
        fetched = await AppointmentService.fetchMyAppointments(widget.doctorId); // doctorId is actually userId in this case
      }
      
      print('✅ Fetched ${fetched.length} appointments');
      setState(() {
        appointments = fetched;
        reminders = List.generate(appointments.length, (_) => true);
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error fetching appointments: $e');
      setState(() {
        isLoading = false;
      });
      // Show error dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to load appointments: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }




  void _showRescheduleDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<PatientDetails?>(
          future: AppointmentService.fetchPatientDetails(appointments[index].userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Text('Loading Patient Details...'),
                content: const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            final patientDetails = snapshot.data;
            
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    child: Text(
                      'Patient Information',
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (patientDetails != null) ...[
                      _buildPatientInfoSection(patientDetails),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 10),
                      _buildAppointmentInfoSection(index),
                    ] else ...[
                      const Text(
                        'Patient details not available',
                        style: TextStyle(
                          color: Colors.red,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildAppointmentInfoSection(index),
                    ]
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          title: const Text("Confirm Cancellation"),
                          content: const Text("Are you sure you want to cancel this appointment?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close confirmation dialog
                              },
                              child: const Text("No"),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  appointments.removeAt(index);
                                  reminders.removeAt(index);
                                });
                                Navigator.pop(context); // Close confirmation dialog
                                Navigator.pop(context); // Close reschedule dialog
                              },
                              child: const Text("Yes"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text('Cancel Appointment'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPatientInfoSection(PatientDetails patient) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Patient Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoRow('Name:', patient.name),
        _buildInfoRow('Gender:', patient.gender),
        if (patient.age.isNotEmpty) _buildInfoRow('Age:', patient.age),
        _buildInfoRow('Profession:', patient.profession),
      ],
    );
  }

  Widget _buildAppointmentInfoSection(int index) {
    final appt = appointments[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Appointment Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoRow('Date:', appt.date),
        _buildInfoRow('Time:', appt.time),
        const SizedBox(height: 8),
        Text(
          'ID: ${appt.appId.substring(0, 8)}...',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(int index) {
    final appt = appointments[index];
    
    // Determine what name to show based on user type
    String displayName = appt.userName;
    
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date at the top
            Text(
              appt.date,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            // Name in bold (Patient name for doctor, Doctor name for patient)
            Text(
              displayName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            // Time below name
            Text(
              appt.time,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            // Appointment ID in small grey text
            Text(
              "ID: ${appt.appId.substring(0, 8)}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.brown),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () => _showRescheduleDialog(context, index),
                  child: const Text('View Details', style: TextStyle(color: Colors.brown)),
                ),
                Row(
                  children: [
                    const Text("Reminder"),
                    Switch(
                      value: reminders[index],
                      activeColor: Colors.green,
                      onChanged: (value) {
                        setState(() => reminders[index] = value);
                      },
                    )
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F6),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFD09ED4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Appointments",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD9CBA4),
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const PendingRequestsPage(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.ease;
                        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                        return SlideTransition(position: animation.drive(tween), child: child);
                      },
                    ),
                  );
                },
                child: const Text("Appointment Requests"),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : appointments.isEmpty
                      ? const Center(child: Text('No confirmed appointments found.'))
                      : ListView.builder(
                          itemCount: appointments.length,
                          itemBuilder: (context, index) => _buildAppointmentCard(index),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
