import 'package:flutter/material.dart';
// Import your ManageAppointments widget file

class PendingRequestsPage extends StatefulWidget {
  const PendingRequestsPage({super.key});

  @override
  State<PendingRequestsPage> createState() => _PendingRequestsPageState();
}

class _PendingRequestsPageState extends State<PendingRequestsPage> {
  bool acceptingAppointments = true;

  List<Map<String, String>> pendingRequests = [
    {
      "name": "Zaima Ahmed",
      "date": "Monday, Dec 12, 2025",
      "time": "10:30 AM",
      "age": "23",
      "gender": "Female",
      "profession": "Student",
      "reason": "Individual Therapy",
    },
    {
      "name": "Michael Smith",
      "date": "Monday, Dec 25, 2025",
      "time": "2:15 PM",
      "age": "30",
      "gender": "Male",
      "profession": "Engineer",
      "reason": "Career Counseling",
    },
    {
      "name": "Emma Davis",
      "date": "Tuesday, Dec 25, 2025",
      "time": "4:00 PM",
      "age": "27",
      "gender": "Female",
      "profession": "Teacher",
      "reason": "Stress Management",
    },
  ];

  void _acceptRequest(int index) {
    setState(() {
      pendingRequests.removeAt(index);
    });
  }

  void _rejectRequest(int index) {
    setState(() {
      pendingRequests.removeAt(index);
    });
  }

  void _goBackToManage() {
    Navigator.pop(context);  // <-- pops current page to go back
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F6),
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFD09ED4),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _goBackToManage,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Appointment Requests",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text("Accepting New Appointments"),
                      ],
                    ),
                  ),
                  Switch(
                    value: acceptingAppointments,
                    onChanged: (value) {
                      setState(() => acceptingAppointments = value);
                    },
                    activeColor: Colors.green,
                  ),
                ],
              ),
            ),

            // Count
            Text(
              "${pendingRequests.length} pending request${pendingRequests.length == 1 ? '' : 's'}",
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 10),

            // List
            Expanded(
              child: ListView.builder(
                itemCount: pendingRequests.length,
                itemBuilder: (context, index) {
                  final req = pendingRequests[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person),
                              const SizedBox(width: 8),
                              Text(req["name"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const Spacer(),
                              const Text("🟡Pending", style: TextStyle(color: Colors.orange)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16),
                              const SizedBox(width: 6),
                              Text(req["date"]!),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 16),
                              const SizedBox(width: 6),
                              Text(req["time"]!),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () => _acceptRequest(index),
                                  icon: const Icon(Icons.check),
                                  label: const Text("Accept"),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD9CBA4),
                                    foregroundColor: Colors.red,
                                  ),
                                  onPressed: () => _rejectRequest(index),
                                  icon: const Icon(Icons.close),
                                  label: const Text("Reject"),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
