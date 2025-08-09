import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

enum AppointmentStatus { booked, completed, cancelled }

class Appointment {
  final String name;
  final String institution;
  final String imagepath;
  final String location;
  final DateTime dateTime;
  final String specialty;
  final AppointmentStatus status;

  Appointment({
    required this.name,
    required this.institution,
    required this.imagepath,
    required this.location,
    required this.dateTime,
    required this.specialty,
    required this.status,
  });
}

class BookedAppointments extends StatelessWidget {
  final List<Appointment> appointments;

  const BookedAppointments({super.key, required this.appointments});

  @override
  Widget build(BuildContext context) {
    final purple = const Color.fromARGB(255, 211, 154, 213);
    final now = DateTime.now();
    final upcoming = appointments
        .where((a) => a.dateTime.isAfter(now))
        .toList();
    final past = appointments.where((a) => !a.dateTime.isAfter(now)).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: purple,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          title: Text(
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
        body: TabBarView(
          children: [
            _buildAppointmentList(context, upcoming, purple),
            _buildAppointmentList(context, past, purple),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentList(
    BuildContext context,
    List<Appointment> appts,
    Color accent,
  ) {
    if (appts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'No appointments found.',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appts.length,
      itemBuilder: (context, index) {
        final appt = appts[index];
        return LayoutBuilder(
          builder: (context, constraints) => ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth),
            child: Container(
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Small circular doctor image
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundImage: AssetImage(appt.imagepath),
                      backgroundColor: Colors.purple[100],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                '${appt.name}, ${appt.specialty}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.purple[900],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _statusChip(appt.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appt.institution,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.place,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                appt.location,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _chip(
                              icon: Icons.calendar_today,
                              label: DateFormat(
                                'MMMM d, yyyy',
                              ).format(appt.dateTime),
                            ),
                            _chip(
                              icon: Icons.access_time,
                              label: DateFormat(
                                'hh:mm a',
                              ).format(appt.dateTime),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                // You can show appointment details here
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    title: Text(
                                      '${appt.name}, ${appt.specialty}',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 6),
                                        Text(
                                          '🩺 Institution: ${appt.institution}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          '📍 Location: ${appt.location}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          '📅 Date: ${DateFormat('MMMM d, yyyy').format(appt.dateTime)}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          '⏰ Time: ${DateFormat('hh:mm a').format(appt.dateTime)}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          'Close',
                                          style: GoogleFonts.poppins(),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(Icons.visibility, size: 18),
                              label: Text(
                                'View Details',
                                style: GoogleFonts.poppins(fontSize: 13),
                              ),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    title: const Text('Cancel Appointment'),
                                    content: const Text(
                                      'Are you sure you want to cancel this appointment?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('No'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // Handle cancellation logic here
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Appointment with ${appt.name} cancelled',
                                              ),
                                              backgroundColor: Colors.red[300],
                                            ),
                                          );
                                        },
                                        child: const Text('Yes'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.cancel,
                                size: 18,
                                color: Colors.redAccent,
                              ),
                              label: Text(
                                'Cancel',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
}
