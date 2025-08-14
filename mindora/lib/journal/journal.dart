import 'package:client/navbar/navbar.dart';
import 'package:flutter/material.dart';
import '../journal/journal_history.dart';
import '../dashboard/p_dashboard.dart'; 
import 'backend.dart';
import 'mood_detector.dart'; // Add this import

class JournalPage extends StatefulWidget {
  final String userId;
  
  const JournalPage({super.key, required this.userId});
  final String userId;
  
  const JournalPage({super.key, required this.userId});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String currentMood = 'neutral';
  Color currentMoodColor = MoodDetector.getMoodColor('neutral');

  @override
  void initState() {
    super.initState();
    // Listen to text changes for real-time mood detection
    _titleController.addListener(_updateMood);
    _contentController.addListener(_updateMood);
  }

  void _updateMood() {
    final combinedText = '${_titleController.text} ${_contentController.text}';
    final detectedMood = MoodDetector.detectMood(combinedText);
    final moodColor = MoodDetector.getMoodColor(detectedMood);
    
    if (detectedMood != currentMood) {
      setState(() {
        currentMood = detectedMood;
        currentMoodColor = moodColor;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveJournal() async {
    String title = _titleController.text.trim();
    String content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something before saving!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Dismiss the keyboard FIRST
    FocusScope.of(context).unfocus();
    
    // Wait for keyboard to fully dismiss before showing popup
    await Future.delayed(const Duration(milliseconds: 300));

    print('🔍 Current mood before dialog: $currentMood'); // Debug print

    // Show mood selection popup after keyboard is dismissed
    final selectedMood = await _showMoodSelectionDialog();
    
    print('🔍 Selected mood from dialog: $selectedMood'); // Debug print
    
    if (selectedMood == null) {
      print('❌ User cancelled mood selection');
      return; // User cancelled
    }

    try {
      print('🔍 About to save with mood: $selectedMood'); // Debug print
      // Ensure we have a valid mood string
      final moodToSave = selectedMood.isNotEmpty ? selectedMood : 'neutral';
      print('🔍 Final mood to save: $moodToSave'); // Debug print
      
      await saveJournalEntry(title, content, widget.userId, moodToSave);

      // Clear the text fields and remove focus
      setState(() {
        _titleController.clear();
        _contentController.clear();
        currentMood = 'neutral';
        currentMoodColor = MoodDetector.getMoodColor('neutral');
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Journal saved with ${MoodDetector.getMoodDisplayName(moodToSave)} mood!'),
          backgroundColor: MoodDetector.getMoodColor(moodToSave),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('❌ Error in _handleSaveJournal: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save journal.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<String?> _showMoodSelectionDialog() async {
    String selectedMood = currentMood;
    
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.mood, color: MoodDetector.getMoodColor(selectedMood)),
                  const SizedBox(width: 8),
                  const Text('Select Your Mood'),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Detected mood: ${MoodDetector.getMoodDisplayName(currentMood)}',
                      style: TextStyle(
                        color: MoodDetector.getMoodColor(currentMood),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Choose your mood:'),
                    const SizedBox(height: 12),
                    ...MoodDetector.moodColors.keys.where((mood) => mood != 'neutral').map((mood) {
                      final isSelected = selectedMood == mood;
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: Icon(
                            MoodDetector.getMoodIcon(mood),
                            color: MoodDetector.getMoodColor(mood),
                          ),
                          title: Text(MoodDetector.getMoodDisplayName(mood)),
                          trailing: isSelected 
                            ? Icon(Icons.check_circle, color: MoodDetector.getMoodColor(mood))
                            : const Icon(Icons.radio_button_unchecked),
                          tileColor: isSelected 
                            ? MoodDetector.getMoodColor(mood).withOpacity(0.1)
                            : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: isSelected 
                              ? BorderSide(color: MoodDetector.getMoodColor(mood), width: 2)
                              : BorderSide.none,
                          ),
                          onTap: () {
                            setState(() {
                              selectedMood = mood;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(selectedMood),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MoodDetector.getMoodColor(selectedMood),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // When navigating to history page, pass the user ID
  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JournalHistoryPage(userId: widget.userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const MainNavBar(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(-1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.ease;
                  final tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              ),
            );
          },
        ),
        title: const Text(
          "New Journal",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        actions: [
          // Mood indicator in app bar
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: currentMoodColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              MoodDetector.getMoodIcon(currentMood),
              color: currentMoodColor,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.history, color: Colors.black54),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JournalHistoryPage(userId: widget.userId),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Title your journal...',
                hintStyle: const TextStyle(color: Colors.black54),
                border: InputBorder.none,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: currentMoodColor, width: 2),
                ),
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: currentMoodColor.withOpacity(0.15), // Dynamic color based on mood
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: currentMoodColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Write your thoughts here...',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentMoodColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _handleSaveJournal,
                child: Text(
                  'Save Journal - ${MoodDetector.getMoodDisplayName(currentMood)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
