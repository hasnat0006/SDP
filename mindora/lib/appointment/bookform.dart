import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'backend.dart';

class BookForm extends StatefulWidget {
  final String name;
  final String institution;
  final String imagepath;
  final String shortbio;
  final String education;
  final String description;
  final String special;
  final String exp;
  final String userId;
  final String docId;

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
    required this.userId,
    required this.docId,
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
  TextEditingController reasonController =
      TextEditingController(); // Reason text field controller

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
 Future<void> _submitForm() async {
    if (selectedDate != null &&
        selectedTime != null &&
        reasonController.text.isNotEmpty) {
      final String reason = reasonController.text.trim();
      final String email = emailController.text.trim();

      // Prepare the data to send
      final appointmentData = {
        'docId': widget.docId,
        'userId': widget.userId,
        'name': widget.name,
        'institution': widget.institution,
        'date': selectedDate?.toIso8601String(),
        'time': selectedTime,
        'reason': reason,
        'email': email.isEmpty ? '' : email,
      };

      // Call the backend function to book the appointment
      try {
        await bookAppointment(
          docId: widget.docId,
          userId: widget.userId,
          name: widget.name,
          institution: widget.institution,
          date: selectedDate?.toIso8601String() ?? '',
          time: selectedTime ?? '',
          reason: reason,
          email: email,
        );

        // Show a confirmation message
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Success"),
              content: const Text("Your appointment has been booked successfully!"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      } catch (error) {
        // Show an error message if something goes wrong
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: const Text("There was an issue booking your appointment. Please try again."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }
    }
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
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                widget.institution,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 6),
              const SizedBox(height: 18),

              // Reason Input Field
              const Text('Reason', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: 'Enter reason',
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

              // Date and Time Picker
              ElevatedButton.icon(
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
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),

              // Time Slots
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
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Selected Date and Time
              if (selectedDate != null && selectedTime != null)
                Text(
                  'You\'ve selected ${DateFormat('MMMM d, yyyy').format(selectedDate!)} at $selectedTime',
                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                ),

              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: (selectedDate != null && selectedTime != null)
                    ? _submitForm // Call the function when the button is pressed
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
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
