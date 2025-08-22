import 'package:client/forum/forum.dart';
import 'package:client/services/user_service.dart';
import 'package:client/therapist/backend.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../therapist/manage_app.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  String _userId = '';
  String _userType = '';
  String _userName = '';
  List<Map<String, String>> todayAppointments = [];
  bool isLoadingAppointments = true;
  List<int> monthlyStats = List.generate(12, (index) => 0);
  bool isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadTodayAppointments();
    _loadMonthlyStats();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await UserService.getUserData();
      if (mounted) {
        setState(() {
          _userId = userData['userId'] ?? '';
          _userType = userData['userType'] ?? '';
          _userName = userData['userName'] ?? 'Doctor';
        });
      }
      print('Loaded doctor data - ID: $_userId, Type: $_userType, Name: $_userName');
      
      
      if (_userType == 'patient') {
        print('⚠️ Patient account detected in doctor dashboard - skipping appointment loading');
        return;
      }
    } catch (e) {
      print('Error loading doctor data: $e');
    }
  }

  Future<void> _loadTodayAppointments() async {
    try {
      
      if (_userType == 'patient') {
        print('⚠️ Skipping appointment loading for patient account');
        if (mounted) {
          setState(() {
            isLoadingAppointments = false;
          });
        }
        return;
      }
      
      
      final appointments = await AppointmentService.fetchConfirmedAppointmentsForDoctor(_userId);
      
     
      final today = DateTime.now();
      final todayStr = '${today.day}/${today.month}/${today.year}';
      
      List<Map<String, String>> todayAppts = [];
      for (var appt in appointments) {
        if (appt.date == todayStr) {
          // Fetch patient details for each appointment
          final patientDetails = await AppointmentService.fetchPatientDetails(appt.userId);
          
          todayAppts.add({
            'date': appt.date,
            'time': appt.time,
            'name': appt.userName,
            'age': patientDetails?.age ?? '',
            'gender': patientDetails?.gender ?? '',
            'profession': patientDetails?.profession ?? '',
            'reason': 'Consultation', 
          });
        }
      }
      
      if (mounted) {
        setState(() {
          todayAppointments = todayAppts;
          isLoadingAppointments = false;
        });
      }
    } catch (e) {
      print('Error loading today appointments: $e');
      if (mounted) {
        setState(() {
          isLoadingAppointments = false;
        });
      }
    }
  }

  Future<void> _loadMonthlyStats() async {
    try {
      if (_userId.isEmpty) {
        
        await _loadUserData();
      }
      
      if (_userType == 'patient') {
        print('⚠️ Skipping stats loading for patient account');
        if (mounted) {
          setState(() {
            isLoadingStats = false;
          });
        }
        return;
      }
      
      final stats = await AppointmentService.fetchMonthlyAppointmentStats(_userId);
      
      if (mounted) {
        setState(() {
          monthlyStats = stats;
          isLoadingStats = false;
        });
      }
    } catch (e) {
      print('Error loading monthly stats: $e');
      if (mounted) {
        setState(() {
          monthlyStats = List.generate(12, (index) => 0);
          isLoadingStats = false;
        });
      }
    }
  }

  final List<Map<String, String>> appointments = const [];

  Widget _buildHeader() {
    final String formattedDate = DateFormat('EEE, dd MMM yyyy').format(DateTime.now());
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD1A1E3),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage('assets/nabiha.jpg'), 
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Welcome Back,",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "Dr. $_userName!",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridButtons(BuildContext context) {
    // Use fixed constants for button size
    const double buttonHeight = 110;
    const double buttonWidth = 110;
    return Padding(
      padding: const EdgeInsets.only(top: 18.0, bottom: 12.0),
      child: Row(
        children: [
          // Manage Appointments Button
          Expanded(
            child: SizedBox(
              height: buttonHeight,
              width: buttonWidth,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 160, 191, 229), // Purple
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadowColor: Colors.grey.withOpacity(0.18),
                  padding: EdgeInsets.zero,
                ),
                onPressed: () async {
                  
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ManageAppointments(),
                    ),
                  );
                  
                  
                  print('🔄 Returned from manage appointments, refreshing dashboard...');
                  if (mounted) {
                   
                    setState(() {
                      isLoadingStats = true;
                    });
                    await _loadMonthlyStats();
                    
                   
                    setState(() {
                      isLoadingAppointments = true;
                    });
                    await _loadTodayAppointments();
                    
                    print('✅ Dashboard data refreshed');
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.access_time, color: Colors.white, size: 54),
                    SizedBox(height: 10),
                    Text(
                      "Manage Appointments",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Forums Button
          Expanded(
            child: SizedBox(
              height: buttonHeight,
              width: buttonWidth,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF7B2B7), // Pink
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadowColor: Colors.grey.withOpacity(0.18),
                  padding: EdgeInsets.zero,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ForumPage()),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.forum_outlined, color: Colors.white, size: 54),
                    SizedBox(height: 10),
                    Text(
                      "Forums",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final Color barColor = const Color.fromARGB(255, 163, 234, 176);
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final now = DateTime.now();
    final currentMonth = now.month;

    if (isLoadingStats) {
      return Container(
        margin: const EdgeInsets.only(top: 8, bottom: 20),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    
    final List<int> data = monthlyStats;
    final int maxVal = data.isEmpty ? 1 : data.reduce((a, b) => a > b ? a : b);
    final int displayMaxVal = maxVal == 0 ? 1 : maxVal;

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 20),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Appointments in 2025",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextButton(
                onPressed: () async {
                  // Refresh monthly stats
                  setState(() {
                    isLoadingStats = true;
                  });
                  await _loadMonthlyStats();
                },
                child: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(12, (i) {
                final double barHeight = displayMaxVal > 0 ? (data[i] / displayMaxVal) * 120 : 0;
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: barHeight,
                        width: 18,
                        decoration: BoxDecoration(
                          color: data[i] > 0 ? barColor : Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: data[i] > 0
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Text(
                                    '${data[i]}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        months[i],
                        style: TextStyle(
                          fontSize: 12,
                          color: i < currentMonth ? Colors.black87 : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTitle() {
    return const Padding(
      padding: EdgeInsets.only(top: 10, bottom: 12),
      child: Text(
        "Upcoming Today",
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

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

  Widget _buildAppointmentCard(BuildContext context, Map<String, String> appt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${appt["date"]} at ${appt["time"]}",
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(appt["name"] ?? "",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Confirmed",
                  style: TextStyle(fontSize: 12, color: Colors.green),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Appointment Details"),
                    content: Table(
                      columnWidths: const {
                        0: IntrinsicColumnWidth(),
                        1: FlexColumnWidth(),
                      },
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      children: [
                        _buildTableRow("Patient Name:", appt["name"] ?? ""),
                        _buildTableRow("Age:", appt["age"] ?? ""),
                        _buildTableRow("Gender:", appt["gender"] ?? ""),
                        _buildTableRow("Profession:", appt["profession"] ?? ""),
                        _buildTableRow("Date:", appt["date"] ?? ""),
                        _buildTableRow("Time:", appt["time"] ?? ""),
                        _buildTableRow("Reason:", appt["reason"] ?? ""),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Close"),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD9C294),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("View Details"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(BuildContext context) {
    if (isLoadingAppointments) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (todayAppointments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32.0),
        child: const Center(
          child: Text(
            'No appointments scheduled for today',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Column(
      children: todayAppointments
          .map((appt) => _buildAppointmentCard(context, appt))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F4F1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildGridButtons(context),
              _buildBarChart(),
              _buildUpcomingTitle(),
              _buildAppointmentsList(context),
            ],
          ),
        ),
      ),
    );
  }
}