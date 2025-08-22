import 'package:flutter/material.dart';
import 'package:client/services/user_service.dart';
import './backend.dart';

class PendingRequestsPage extends StatefulWidget {
  const PendingRequestsPage({Key? key}) : super(key: key);

  @override
  State<PendingRequestsPage> createState() => _PendingRequestsPageState();
}

class _PendingRequestsPageState extends State<PendingRequestsPage> {
  bool acceptingAppointments = true;
  List<Appointment> pendingRequests = [];
  bool isLoading = true;
  String _userId = '';
  String _userType = '';

  @override
  void initState() {
    super.initState();
    _loadUserDataAndFetchRequests();
  }

  Future<void> _loadUserDataAndFetchRequests() async {
    try {
      // Load user data first
      final userData = await UserService.getUserData();
      setState(() {
        _userId = userData['userId'] ?? '';
        _userType = userData['userType'] ?? '';
      });
      
      print('Loaded user data in pending requests - ID: $_userId, Type: $_userType');
      
      // Then fetch pending requests
      await _fetchPendingRequests();
    } catch (e) {
      print('❌ Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to load user data: $e');
    }
  }

  Future<void> _fetchPendingRequests() async {
    try {
      print('🔄 Fetching pending appointments for doctor: $_userId');
      
      final fetched = await AppointmentService.fetchPendingAppointmentsForDoctor(_userId);
      
      print('✅ Fetched ${fetched.length} pending appointments');
      
      if (mounted) {
        setState(() {
          pendingRequests = fetched;
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error fetching pending appointments: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(message),
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

  void _acceptRequest(int index) async {
    final appointmentId = pendingRequests[index].appId;
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: const [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Accepting appointment...'),
          ],
        ),
      ),
    );

    try {
      final success = await AppointmentService.updateAppointmentStatus(appointmentId, 'confirmed');
      
      // Close loading dialog
      Navigator.pop(context);
      
      if (success) {
        setState(() {
          pendingRequests.removeAt(index);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment accepted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to accept appointment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _rejectRequest(int index) async {
    final appointmentId = pendingRequests[index].appId;
    
    // Show confirmation dialog
    final shouldReject = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Appointment'),
        content: const Text('Are you sure you want to reject this appointment request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldReject != true) return;
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: const [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Rejecting appointment...'),
          ],
        ),
      ),
    );

    try {
      final success = await AppointmentService.updateAppointmentStatus(appointmentId, 'cancelled');
      
      // Close loading dialog
      Navigator.pop(context);
      
      if (success) {
        setState(() {
          pendingRequests.removeAt(index);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment rejected successfully'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to reject appointment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : pendingRequests.isEmpty
                      ? const Center(
                          child: Text(
                            'No pending appointment requests',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
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
                                        Text(req.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        const Spacer(),
                                        const Text("🟡Pending", style: TextStyle(color: Colors.orange)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 16),
                                        const SizedBox(width: 6),
                                        Text(req.date),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, size: 16),
                                        const SizedBox(width: 6),
                                        Text(req.time),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "ID: ${req.appId.substring(0, 8)}...",
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
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
