import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MoodStatsPage extends StatelessWidget {
  final DateTime selectedDate;

  const MoodStatsPage({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat.yMMMMd().format(selectedDate);

    final List<Map<String, String>> weeklyOverview = [
      {"week": "Week 1", "range": "Jan 1-7", "summary": "Mostly Happy"},
      {"week": "Week 2", "range": "Jan 8-14", "summary": "Mixed Feelings"},
      {"week": "Week 3", "range": "Jan 15-21", "summary": "Improving"},
      {"week": "Week 4", "range": "Jan 22-28", "summary": "Steady"},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.brown),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Mood Stats",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown.shade800,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.bar_chart, color: Colors.brown),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "See your mood trend for selected date",
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    formattedDate,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.brown),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Info Cards Section
              Column(
                children: [
                  _InfoCard(
                    title: "Mood",
                    value: "A bit sad",
                    icon: Icons.cloud_outlined,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    title: "Stress Level",
                    value: "6/10",
                    icon: Icons.bar_chart,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    title: "Sleep",
                    value: "6.5 hours",
                    icon: Icons.nightlight_round,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(height: 12),

                  // Image container styled like a card
            const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/sunrise.png',
                        height: 165,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 20),
                ],
              ),

              const SizedBox(height: 8),
              Text(
                "Remember to take deep breaths and stay calm",
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
              ),

              const SizedBox(height: 30),
              Text(
                "Weekly Overview",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 12),

              Column(
                children: weeklyOverview.map((weekData) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2E3F4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(weekData["week"]!,
                            style: GoogleFonts.poppins(
                                fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey.shade600)),
                        Text(weekData["range"]!,
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500)),
                        const SizedBox(height: 6),
                        Text(
                          weekData["summary"]!,
                          style: GoogleFonts.poppins(
                              fontSize: 14, fontWeight: FontWeight.w600, color: Colors.deepPurple),
                        )
                      ],
                    ),
                  );
                }).toList(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700)),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.brown,
                ),
              ),
            ],
          ),
          Icon(icon, color: color, size: 24),
        ],
      ),
    );
  }
}
