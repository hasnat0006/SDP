import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'Selected_mood_stats.dart';

class MoodInsightsPage extends StatefulWidget {
  const MoodInsightsPage({super.key});

  @override
  State<MoodInsightsPage> createState() => _MoodInsightsPageState();
}

class _MoodInsightsPageState extends State<MoodInsightsPage> {
  DateTime? selectedDate;
// Filter Tabs
final List<String> filters = ["1 Week", "1 Month", "1 Year", "All Time"];
int selectedFilterIndex = 0; // Default to "1 Week"
String getCurrentWeekRange() {
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final endOfWeek = startOfWeek.add(const Duration(days: 6));
  final formatter = DateFormat.MMMd();
  return "${formatter.format(startOfWeek)} - ${formatter.format(endOfWeek)}";
}



 void _pickDate() async {
  DateTime now = DateTime.now();
  DateTime? picked = await showDatePicker(
    context: context,
    initialDate: selectedDate ?? now,
    firstDate: DateTime(now.year - 2),
    lastDate: DateTime(now.year + 2),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFB79AE0),
            onPrimary: Colors.white,
            surface: Color(0xFFFFF9F4),
            onSurface: Colors.brown,
          ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null) {
    setState(() => selectedDate = picked);

    // Navigate to MoodStatsPage after selection
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MoodStatsPage(selectedDate: picked),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    final moodIcons = [
      Icons.sentiment_very_satisfied,
      Icons.sentiment_satisfied,
      Icons.sentiment_neutral,
      Icons.sentiment_dissatisfied,
      Icons.sentiment_very_dissatisfied,
      Icons.mood,
      Icons.emoji_emotions,
    ];
    final moodColors = [
      Colors.green,
      Colors.lightGreen,
      Colors.orangeAccent,
      Colors.deepOrange,
      Colors.redAccent,
      Colors.blueAccent,
      Colors.purpleAccent,
    ];

return Scaffold(
  backgroundColor: const Color(0xFFFFF9F4),
  appBar: AppBar(
    backgroundColor: const Color(0xFFD39AD5),
    elevation: 0,
    toolbarHeight: 80,
    centerTitle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
    ),
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color.fromARGB(255, 2, 2, 2)),
      onPressed: () => Navigator.pop(context),
    ),
    title: Text(
      "Mood Today",
      style: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: const Color.fromARGB(255, 15, 15, 15),
      ),
    ),
  ),
  body: SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
  

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.nightlight_round, color: Color(0xFFB79AE0)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Today you felt a bit down",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "It's okay to have such days",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/insights.png',
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.monitor_heart, color: Colors.deepPurple),
                                const SizedBox(width: 6),
                                Text(
                                  "Stress Level",
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Moderate stress detected today",
                              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          backgroundColor: const Color(0xFFEEE6FA),
                          radius: 18,
                          child: Text(
                            "3",
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 16),
Divider(
  thickness: 0.5,
  color: Colors.grey,
  height: 10,
),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.bedtime_rounded, color: Colors.deepPurple),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("7.5 hours of sleep", style: GoogleFonts.poppins(fontSize: 14)),
                            Text("Slightly below your average", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600))
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Align(
  alignment: Alignment.centerLeft,
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        "History: ",
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade700,
        ),
      ),
      GestureDetector(
        onTap: _pickDate,
        child: const Icon(Icons.calendar_today, size: 16, color: Colors.deepPurple),
      ),
      const SizedBox(width: 4),
      GestureDetector(
        onTap: _pickDate,
        child: Text(
          selectedDate == null
              ? DateFormat.MMMd().format(DateTime.now())
              : DateFormat.MMMd().format(selectedDate!),
          style: GoogleFonts.poppins(
            color: Colors.deepPurple,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      )
    ],
  ),
),

              const SizedBox(height: 30),
              Text(
                "Mood Stats",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "See your mood trends across different time periods.",
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),



Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(32),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 6,
        offset: const Offset(0, 3),
      ),
    ],
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: List.generate(filters.length, (index) {
      final isSelected = index == selectedFilterIndex;

      return GestureDetector(
        onTap: () {
          setState(() {
            selectedFilterIndex = index;
          });
        },
        child: AnimatedContainer(
  duration: const Duration(milliseconds: 200),
  curve: Curves.easeOut,
  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8), // tighter
  margin: const EdgeInsets.symmetric(horizontal: 3), // tighter
  decoration: BoxDecoration(
    color: isSelected ? const Color(0xFFB79E91) : Colors.transparent,
    borderRadius: BorderRadius.circular(24),
  ),
  child: Text(
    filters[index],
    style: GoogleFonts.poppins(
      color: isSelected ? Colors.white : Colors.brown.shade700,
      fontWeight: FontWeight.w500,
      fontSize: 12.5,
    ),
  ),
),

      );
    }),
  ),
),




const SizedBox(height: 16),


ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/graph.png',
                        height: 310,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 20),


              const SizedBox(height: 20),
              // Right-aligned: History: [calendar icon] [date]

const SizedBox(height: 10),

// Title: Mood History + current week range
Text(
  "Mood History (${getCurrentWeekRange()})",
  style: GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.brown,
  ),
),

const SizedBox(height: 8),


              const SizedBox(height: 12),

              //Mood History Icons

Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: List.generate(7, (index) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: moodColors[index].withOpacity(0.15),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: moodColors[index].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            moodIcons[index],
            color: moodColors[index],
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            days[index],
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.brown.shade700,
            ),
          ),
        ],
      ),
    );
  }),
),




              // const SizedBox(height: 40),
              // Center(
              //   child: ElevatedButton(
              //     onPressed: () {},
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: const Color(0xFFB79AE0),
              //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              //       padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              //     ),
              //     child: Text("Check Mood Stats →", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
