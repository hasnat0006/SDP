import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'backend.dart'; // Make sure this has GetAppointments()

enum AppointmentStatus { booked, completed, cancelled }

class Appointment {
  final String id; // Add this line
  final String name;
  final String profession;
  final String location;
  final DateTime dateTime;
  final AppointmentStatus status;

  Appointment({
    required this.id, // Add this line
    required this.name,
    required this.profession,
    required this.location,
    required this.dateTime,
    this.status = AppointmentStatus.booked,
  });
}

class BookedAppointments extends StatefulWidget {
  final String userId;

  const BookedAppointments({super.key, required this.userId});

  @override
  State<BookedAppointments> createState() => _BookedAppointmentsState();
}

class _BookedAppointmentsState extends State<BookedAppointments> {
  List<Appointment> appts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    try {
      print("🔍 Fetching appointments for user: ${widget.userId}");
      final data = await GetAppointments(widget.userId);
      print("📦 Raw appointment data: $data");

      if (data.isEmpty) {
        print("⚠️ No appointments found");
        setState(() {
          appts = [];
          isLoading = false;
        });
        return;
      }

      List<Appointment> appointments = data.map<Appointment>((item) {
        print("🔄 Processing appointment item: $item");

        // Map status from backend to enum
        AppointmentStatus status = AppointmentStatus.booked;
        String statusStr = (item['status'] ?? 'Pending').toLowerCase();

        switch (statusStr) {
          case 'completed':
            status = AppointmentStatus.completed;
            break;
          case 'cancelled':
            status = AppointmentStatus.cancelled;
            break;
          case 'pending':
          default:
            status = AppointmentStatus.booked;
            break;
        }
        final appointment = Appointment(
          id: item['appointment_id'].toString(), // Add this line
          name: item['name'] ?? '',
          profession: item['profession'] ?? 'Unknown',
          location: item['location'] ?? 'Not specified',
          dateTime: DateTime.parse(item['datetime']),
          status: status,
        );
        print("✅ Created appointment object: $appointment");
        return appointment;
      }).toList();

      print("📋 Final appointments list: $appointments");
      setState(() {
        appts = appointments;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error in fetchAppointments: $e");
      setState(() {
        appts = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final purple = const Color.fromARGB(255, 211, 154, 213);
    final now = DateTime.now();
    final upcoming = appts.where((a) => a.dateTime.isAfter(now)).toList();
    final past = appts.where((a) => !a.dateTime.isAfter(now)).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: purple,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          title: const Text(
            'Your Appointments',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildAppointmentList(upcoming),
                  _buildAppointmentList(past),
                ],
              ),
      ),
    );
  }

  Widget _buildAppointmentList(List<Appointment> list) {
    if (list.isEmpty) {
      return Center(
        child: Text(
          'No appointments found.',
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final appt = list[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.purple[50],
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${appt.name} - ${appt.profession}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple[900],
                      ),
                    ),
                  ),
                  if (appt.status == AppointmentStatus.booked)
                    TextButton(
                      onPressed: () => _showCancelDialog(appt),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: const Text('Cancel'),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                appt.location,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _chip(
                    icon: Icons.calendar_today,
                    label: DateFormat('MMMM d, yyyy').format(appt.dateTime),
                  ),
                  const SizedBox(width: 8),
                  _chip(
                    icon: Icons.access_time,
                    label: DateFormat('hh:mm a').format(appt.dateTime),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _statusChip(appt.status),
            ],
          ),
        );
      },
    );
  }

  Widget _chip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.purple[900]),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.purple[900]),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(AppointmentStatus status) {
    late final Color bg;
    late final Color fg;
    late final String text;

    switch (status) {
      case AppointmentStatus.booked:
        bg = const Color(0xFFE7F6EC);
        fg = const Color(0xFF227A40);
        text = 'Booked';
        break;
      case AppointmentStatus.completed:
        bg = const Color(0xFFE6E9FF);
        fg = const Color(0xFF2A3B9B);
        text = 'Completed';
        break;
      case AppointmentStatus.cancelled:
        bg = const Color(0xFFFFE8E8);
        fg = const Color(0xFF9B2A2A);
        text = 'Cancelled';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  // Add this method to show the cancel confirmation dialog
  void _showCancelDialog(Appointment appt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cancel Appointment?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to cancel this appointment?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              _cancelAppointment(appt);
            },
            child: Text(
              'Yes, Cancel',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // Add this method to handle the cancellation
  Future<void> _cancelAppointment(Appointment appt) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Cancel the appointment
      final success = await cancelAppointment(appt.id.toString());

      // Remove loading indicator
      Navigator.pop(context);

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the appointments list
        await fetchAppointments();
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to cancel appointment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Remove loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
