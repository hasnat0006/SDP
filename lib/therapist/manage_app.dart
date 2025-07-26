import 'package:flutter/material.dart';
import 'pending_req.dart';  // Import your PendingRequestsPage here

class ManageAppointments extends StatefulWidget {
  const ManageAppointments({super.key});

  @override
  State<ManageAppointments> createState() => _ManageAppointmentsState();
}

class _ManageAppointmentsState extends State<ManageAppointments> {
  bool acceptingAppointments = true;

  List<Map<String, String>> appointments = [
    {
      "name": "Zaima Ahmed",
      "age": "23",
      "gender": "Female",
      "profession": "Student",
      "date": "February 15, 2024",
      "time": "10:00 AM",
      "reason": "Individual Therapy",
    },
    {
      "name": "Mehnaj Hridi",
      "age": "29",
      "gender": "Female",
      "profession": "Teacher",
      "date": "February 15, 2024",
      "time": "11:00 AM",
      "reason": "Individual Therapy",
    },
    {
      "name": "Sarah Johnson",
      "age": "29",
      "gender": "Female",
      "profession": "Therapist",
      "date": "February 15, 2024",
      "time": "10:00 AM",
      "reason": "Individual Therapy",
    },
  ];

  List<bool> reminders = [true, true, true];

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  void _showRescheduleDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Appointment Details',
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          content: Table(
            columnWidths: const {
              0: IntrinsicColumnWidth(),
              1: FlexColumnWidth(),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              _buildTableRow("Patient Name:", appointments[index]["name"] ?? ""),
              _buildTableRow("Age:", appointments[index]["age"] ?? ""),
              _buildTableRow("Gender:", appointments[index]["gender"] ?? ""),
              _buildTableRow("Profession:", appointments[index]["profession"] ?? ""),
              _buildTableRow("Date:", appointments[index]["date"] ?? ""),
              _buildTableRow("Time:", appointments[index]["time"] ?? ""),
              _buildTableRow("Reason:", appointments[index]["reason"] ?? ""),
            ],
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
  }

  Widget _buildAppointmentCard(int index) {
    final appt = appointments[index];
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${appt["date"]} at ${appt["time"]}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(appt["name"] ?? "", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text("Confirmed", style: TextStyle(fontSize: 12, color: Colors.green)),
                ),
              ],
            ),
            const SizedBox(height: 10),
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
                  child: const Text('Reschedule', style: TextStyle(color: Colors.brown)),
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
              child: ListView.builder(
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
