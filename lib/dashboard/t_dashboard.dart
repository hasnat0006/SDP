import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class DoctorDashboard extends StatelessWidget {
  const DoctorDashboard({super.key});

  final List<Map<String, String>> appointments = const [
    {
      "date": "July 17, 2025",
      "time": "10:30 AM",
      "name": "Sarah Johnson",
      "age": "28",
      "gender": "Female",
      "profession": "Software Engineer",
      "reason": "Routine check-up"
    },
    {
      "date": "July 17, 2025",
      "time": "11:45 AM",
      "name": "Michael Brown",
      "age": "35",
      "gender": "Male",
      "profession": "Teacher",
      "reason": "Follow-up for blood pressure"
    },
  ];

   Widget _buildHeader() {
  final String formattedDate = DateFormat('EEE, dd MMM yyyy').format(DateTime.now());
  // Example output: Tue, 25 Jan 2025

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
          backgroundImage: AssetImage('assets/zaima.jpg'), // Replace with real image
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formattedDate,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 4),
            const Text(
              "Welcome Back, Dr. Nabiha!",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    ),
  );
}


  Widget _buildUpcomingTitle() {
    return const Padding(
      padding: EdgeInsets.only(top: 28, bottom: 12),
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
  return Column(
    children: appointments
        .map((appt) => _buildAppointmentCard(context, appt))
        .toList(),
  );
}


  Widget _buildManageAppointments() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: const [
          Icon(Icons.access_time, color: Colors.purple),
          SizedBox(width: 12),
          Text("Manage Appointments",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildForums() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: const [
          Icon(Icons.forum_outlined, color: Colors.pink),
          SizedBox(width: 12),
          Text("Forums",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF9F4F1),
    body: SafeArea(
      child: SingleChildScrollView(    // <-- add this scroll view here
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildUpcomingTitle(),
            _buildAppointmentsList(context),
            const SizedBox(height: 16),
            _buildManageAppointments(),
            const SizedBox(height: 16),
            _buildForums(),
          ],
        ),
      ),
    ),
  );
}
}