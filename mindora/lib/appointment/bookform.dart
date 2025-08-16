import 'package:client/dashboard/p_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BookForm extends StatefulWidget {
  final String name;
  final String institution;
  final String imagepath;
  final String shortbio;
  final String education;
  final String description;
  final String special;
  final String exp;

  const BookForm({
    super.key,
    required this.name,
    required this.institution,
    required this.imagepath,
    required this.shortbio,
    required this.education,
    required this.description,
    required this.special,
    required this.exp,
  });

  @override
  State<BookForm> createState() => _BookForm();
}

class _BookForm extends State<BookForm> {
  DateTime? selectedDate;
  String? selectedTime;
  bool isBookingForSomeoneElse = false; // Track if booking for someone else
  TextEditingController emailController =
      TextEditingController(); // Email text field controller

  final List<String> timeSlots = [
    '09:00 AM',
    '10:30 AM',
    '12:00 PM',
    '03:30 PM',
    '05:00 PM',
    '06:30 PM',
  ];

  // Helper to safely prefix "Dr" only once
  String get _doctorDisplayName {
    final n = widget.name.trim();
    final lower = n.toLowerCase();
    return (lower.startsWith('dr ') || lower.startsWith('dr.'))
        ? widget.name
        : 'Dr ${widget.name}';
  }

  Future<void> _showSuccessAndGoToDashboard() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Appointment booked',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Your appointment with $_doctorDisplayName has been booked successfully.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardPage()),
                ),
              },
              child: Text(
                'Close',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.purple[700],
                ),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    // Option A: Navigate by named route (set this in your MaterialApp routes)
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);

    // Option B: Navigate by widget
    // Navigator.pushAndRemoveUntil(
    //   context,
    //   MaterialPageRoute(builder: (_) => const DashboardScreen()),
    //   (route) => false,
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 211, 154, 213),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  widget.imagepath,
                  width: 160,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${widget.name}, Psychiatrist',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.institution,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Uttara, Dhaka, Bangladesh',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About ${widget.name}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple[900],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.shortbio,
                      style: GoogleFonts.poppins(fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Book your appointment today and take the first step toward a healthier mind.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.purple[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              const SizedBox(height: 24),
              Text(
                'Book Your Appointment',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple[900],
                ),
              ),
              const SizedBox(height: 12),

              const Text('Reason', style: TextStyle(fontSize: 16)),
              const SizedBox(
                height: 12,
              ), // Add some spacing between the label and the text field
              TextField(
                decoration: InputDecoration(
                  labelText: 'Enter reason', // Label for the text field
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              // Book for Yourself or Someone Else
              Row(
                children: [
                  Checkbox(
                    value: !isBookingForSomeoneElse,
                    onChanged: (value) {
                      setState(() {
                        isBookingForSomeoneElse = !value!;
                      });
                    },
                  ),
                  const Text(
                    'Book for yourself',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: isBookingForSomeoneElse,
                    onChanged: (value) {
                      setState(() {
                        isBookingForSomeoneElse = value!;
                      });
                    },
                  ),
                  const Text(
                    'Book for someone else',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),

              // Show email field if booking for someone else
              if (isBookingForSomeoneElse) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Enter patient\'s email address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 24),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final selected = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (selected != null) {
                    setState(() {
                      selectedDate = selected;
                    });
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  selectedDate == null
                      ? 'Select Date'
                      : DateFormat('MMMM d, yyyy').format(selectedDate!),
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: timeSlots.map((time) {
                  final isSelected = selectedTime == time;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTime = time;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.purple[300]
                            : Colors.purple[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        time,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              if (selectedDate != null && selectedTime != null)
                Text(
                  'You\'ve selected ${DateFormat('MMMM d, yyyy').format(selectedDate!)} at $selectedTime',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.grey[800],
                  ),
                ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: (selectedDate != null && selectedTime != null)
                    ? () async {
                        // Place any booking API call here if needed.
                        await _showSuccessAndGoToDashboard();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                ),
                child: Text(
                  'Confirm Appointment',
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
