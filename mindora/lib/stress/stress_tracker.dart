import 'package:client/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../stress/stress_insights.dart';
import './backend.dart';

class StressTrackerPage extends StatefulWidget {
  const StressTrackerPage({Key? key}) : super(key: key);

  @override
  _StressTrackerPageState createState() => _StressTrackerPageState();
}

class _StressTrackerPageState extends State<StressTrackerPage> {
  String _userId = '';
  String _userType = '';
  int selectedStressLevel = 3;
  bool isHovering = false;
  String notes = "";
  List<String> stressCauses = [
    'Work/Study',
    'Relationships',
    'Health',
    'Family',
    'Financial',
    'Social Media',
    'Academic',
    'Environmental',
    'Sleep',
    'Time Management',
    'Other',
  ];
  List<String> selectedCauses = [];
  List<String> selectedSymptoms = []; // Symptoms list
  List<IconData> causeIcons = [
    Icons.work, // Work/Study
    Icons.people, // Relationships
    Icons.health_and_safety, // Health
    Icons.family_restroom, // Family
    Icons.account_balance_wallet, // Financial
    Icons.phone_android, // Social Media
    Icons.school, // Academic
    Icons.nature, // Environmental
    Icons.bedtime, // Sleep
    Icons.access_time, // Time Management
    Icons.more_horiz, // Other
  ];

  // Popup related variables
  TextEditingController _otherController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await UserService.getUserData();
      setState(() {
        _userId = userData['userId'] ?? '';
        _userType = userData['userType'] ?? '';
      });
      print('Loaded user data - ID: $_userId, Type: $_userType');
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F0FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD39AD5),
        toolbarHeight: 80,
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Stress Tracker',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Stress Level Rating
                Column(
                  children: [
                    Text(
                      'How stressed are you feeling today?',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6D3670),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '$selectedStressLevel',
                      style: GoogleFonts.poppins(
                        fontSize: 90,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF8E72C7),
                      ),
                    ),
                    Slider(
                      value: selectedStressLevel.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      onChanged: (value) {
                        setState(() {
                          selectedStressLevel = value.toInt();
                        });
                      },
                      activeColor: const Color(0xFFD39AD5),
                      inactiveColor: const Color(0xFF9A77A6),
                    ),
                    Text(
                      _getStressLevelText(selectedStressLevel),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF7A57A6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Stress Cause Options
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What\'s causing your stress?',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6D3670),
                      ),
                    ),
                    const SizedBox(height: 15),
                    GridView.builder(
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                      itemCount: stressCauses.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onDoubleTap: () {
                            setState(() {
                              if (selectedCauses.contains(
                                stressCauses[index],
                              )) {
                                selectedCauses.remove(stressCauses[index]);
                              }
                            });
                          },
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  selectedCauses.contains(stressCauses[index])
                                  ? Color(0xFFD39AD5)
                                  : Color(0xFFEFD1F5), // Lavender button
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              if (stressCauses[index] == 'Other') {
                                _showOtherPopup(context);
                              } else {
                                setState(() {
                                  if (!selectedCauses.contains(
                                    stressCauses[index],
                                  )) {
                                    selectedCauses.add(stressCauses[index]);
                                  }
                                });
                              }
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  causeIcons[index],
                                  size: 32,
                                  color:
                                      selectedCauses.contains(
                                        stressCauses[index],
                                      )
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  stressCauses[index],
                                  style: GoogleFonts.poppins(
                                    color:
                                        selectedCauses.contains(
                                          stressCauses[index],
                                        )
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Selected Causes
                if (selectedCauses.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Causes:',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6D3670),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: selectedCauses.map((cause) {
                          return Chip(
                            label: Text(
                              cause,
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                            backgroundColor: Color(0xFFD39AD5),
                            deleteIcon: Icon(Icons.close, size: 16),
                            onDeleted: () {
                              setState(() {
                                selectedCauses.remove(cause);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                const SizedBox(height: 30),

                // Symptoms Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notice any of these symptoms?',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6D3670),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildCheckbox('Headache'),
                        _buildCheckbox('Tension'),
                        _buildCheckbox('Fatigue'),
                        _buildCheckbox('Anxiety'),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Notes Section
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Add any notes about your stress...',
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      onChanged: (text) {
                        setState(() {
                          notes = text;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Continue Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: MouseRegion(
                    onEnter: (_) => setState(() => isHovering = true),
                    onExit: (_) => setState(() => isHovering = false),
                    child: GestureDetector(
                      onTap: () async {
                        // Save data to backend
                        final result = await StressTrackerBackend.saveStressData(
                          userId: _userId, // Replace with actual logged in user's UUID
                          stressLevel: selectedStressLevel,
                          cause: selectedCauses, // Changed to match backend parameter name
                          loggedSymptoms: selectedSymptoms, // Changed to match backend parameter name
                          Notes: [
                            notes.isNotEmpty ? notes : 'No notes added.',
                          ], // Changed to List<String> as per DB schema
                          date: DateTime.now(),
                        );

                        if (result['success']) {
                          
                          // Navigate to StressInsightsPage with data
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StressInsightsPage(
                                stressLevel: selectedStressLevel,
                                cause: selectedCauses,
                                loggedSymptoms: selectedSymptoms,
                                Notes: [
                                  notes.isNotEmpty ? notes : 'No notes added.',
                                ],
                              ),
                            ),
                          );
                        } else {
                          // Show error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result['message']),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        transform: Matrix4.identity()
                          ..scale(isHovering ? 1.03 : 1.0),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isHovering
                                ? [Color(0xFFE6BCF0), Color(0xFFCF7EE4)]
                                : [Color(0xFFD6A6E1), Color(0xFFB78ED3)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFB89EDF,
                              ).withOpacity(isHovering ? 0.5 : 0.3),
                              blurRadius: isHovering ? 16 : 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "Continue →",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFF9F7F7),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getStressLevelText(int level) {
    switch (level) {
      case 1:
        return 'I feel just a little stressed today.';
      case 2:
        return 'I feel mildly stressed today.';
      case 3:
        return 'I feel moderately stressed today.';
      case 4:
        return 'I feel pretty stressed today.';
      case 5:
        return 'I feel extremely stressed today.';
      default:
        return '';
    }
  }

  Widget _buildCheckbox(String label) {
    return CheckboxListTile(
      title: Text(label, style: GoogleFonts.poppins()),
      value: selectedSymptoms.contains(label),
      onChanged: (bool? value) {
        setState(() {
          if (value == true) {
            selectedSymptoms.add(label);
          } else {
            selectedSymptoms.remove(label);
          }
        });
      },
    );
  }

  void _showOtherPopup(BuildContext context) {
    // Add "Other" cause to selectedCauses before showing the dialog
    if (!selectedCauses.contains('Other')) {
      setState(() {
        selectedCauses.add('Other');
      });
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Please enter your custom cause',
            style: GoogleFonts.poppins(),
          ),
          content: TextField(
            controller: _otherController,
            decoration: InputDecoration(
              labelText: 'Enter custom cause',
              labelStyle: GoogleFonts.poppins(),
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_otherController.text.isNotEmpty) {
                  setState(() {
                    selectedCauses.remove('Other');
                    selectedCauses.add(_otherController.text);
                    _otherController.clear();
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text('OK', style: GoogleFonts.poppins()),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }
}
