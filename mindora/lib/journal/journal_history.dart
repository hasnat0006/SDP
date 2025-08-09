import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'backend.dart'; 
import 'mood_detector.dart';

class JournalHistoryPage extends StatefulWidget {
  final String userId;
  
  const JournalHistoryPage({super.key, required this.userId});

  @override
  State<JournalHistoryPage> createState() => _JournalHistoryPageState();
}

class _JournalHistoryPageState extends State<JournalHistoryPage> {
  String sortOrder = 'Newest';
  List<JournalEntry> journalEntries = [];
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _loadJournalEntries();
  }

  Future<void> _loadJournalEntries() async {
    try {
      final rawEntries = await fetchJournalEntries(widget.userId);

      final List<JournalEntry> loadedEntries = rawEntries.map((json) {
        final j_id = json['j_id'] ?? '';
        final time = json['time'] ?? '00:00';
        final title = json['title'] ?? 'No Title';
        final description = json['information'] ?? '';
        final dateStr = json['date'] ?? DateTime.now().toIso8601String();
        final mood = json['mood'] ?? 'neutral';

        // Parse date string
        DateTime dateTime;
        try {
          dateTime = DateTime.parse(dateStr);
        } catch (_) {
          dateTime = DateTime.now();
        }

        // Parse mood color with better handling
        Color moodColor = MoodDetector.getMoodColor(mood);
        if (json['mood_color'] != null) {
          try {
            final colorStr = json['mood_color'].toString().replaceAll('#', '');
            if (colorStr.isNotEmpty) {
              moodColor = Color(int.parse('FF$colorStr', radix: 16));
            }
          } catch (e) {
            print('Error parsing mood color: $e, using default color for mood: $mood');
            moodColor = MoodDetector.getMoodColor(mood);
          }
        }

        print('Entry: $title, Mood: $mood, Color: $moodColor'); // Debug

        return JournalEntry(
          id: j_id,
          time: time,
          title: title,
          description: description,
          dateTime: dateTime,
          mood: mood,
          moodColor: moodColor,
        );
      }).toList();

      setState(() {
        journalEntries = loadedEntries;
      });
    } catch (e) {
      debugPrint('Error loading journal entries: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<JournalEntry> filteredEntries = [...journalEntries];

    // Filter entries based on selected date
    if (selectedDate != null) {
      filteredEntries = filteredEntries.where((entry) {
        return entry.dateTime.year == selectedDate!.year &&
            entry.dateTime.month == selectedDate!.month &&
            entry.dateTime.day == selectedDate!.day;
      }).toList();
    }

    List<JournalEntry> sortedEntries = [...filteredEntries];

    // Sort by combined date and time
    sortedEntries.sort((a, b) {
      DateTime parseFullDateTime(JournalEntry entry) {
        try {
          final timeParts = entry.time.split(':');
          final hour = int.tryParse(timeParts[0]) ?? 0;
          final minute = timeParts.length > 1 ? int.tryParse(timeParts[1]) ?? 0 : 0;
          final second = timeParts.length > 2 ? int.tryParse(timeParts[2]) ?? 0 : 0;

          return DateTime(
            entry.dateTime.year,
            entry.dateTime.month,
            entry.dateTime.day,
            hour,
            minute,
            second,
          );
        } catch (_) {
          return entry.dateTime;
        }
      }

      final aDateTime = parseFullDateTime(a);
      final bDateTime = parseFullDateTime(b);

      if (sortOrder == 'Newest') {
        return bDateTime.compareTo(aDateTime);
      } else {
        return aDateTime.compareTo(bDateTime);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Journal History',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildDateScroller(),
            const SizedBox(height: 20),
            _buildSortDropdown(),
            const SizedBox(height: 10),
            Expanded(
              child: sortedEntries.isEmpty
                  ? const Center(
                      child: Text(
                        'No journal entries found',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: sortedEntries.length,
                      itemBuilder: (context, index) {
                        final entry = sortedEntries[index];
                        return _buildJournalTile(entry);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateScroller() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = startOfWeek.add(Duration(days: index));
          final weekday = DateFormat.E().format(date);
          final day = DateFormat.d().format(date);
          
          final isSelected = selectedDate != null && 
              selectedDate!.year == date.year &&
              selectedDate!.month == date.month &&
              selectedDate!.day == date.day;

          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  selectedDate = null;
                } else {
                  selectedDate = DateTime(date.year, date.month, date.day);
                }
              });
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6A1B9A) : const Color(0xFFF3E9FF),
                borderRadius: BorderRadius.circular(12),
                border: isSelected 
                    ? Border.all(color: const Color(0xFF4A148C), width: 2)
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF6A1B9A).withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                "$weekday\n$day",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        DropdownButton<String>(
          value: sortOrder,
          underline: const SizedBox(),
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black87),
          items: ['Newest', 'Oldest'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              sortOrder = newValue!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildJournalTile(JournalEntry entry) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Enhanced mood color background
        color: entry.moodColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: entry.moodColor.withOpacity(0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: entry.moodColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                entry.time,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: entry.moodColor.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('dd/MM/yyyy').format(entry.dateTime),
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              // Enhanced mood indicator
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: entry.moodColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: entry.moodColor.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  MoodDetector.getMoodIcon(entry.mood),
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                MoodDetector.getMoodDisplayName(entry.mood),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: entry.moodColor,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.description,
                  style: const TextStyle(color: Colors.black87),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: entry.moodColor),
            onSelected: (value) {
              if (value == 'edit') {
                _showEditDialog(entry);
              } else if (value == 'delete') {
                _showDeleteDialog(entry);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit, color: Colors.grey),
                  title: Text('Edit'),
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(JournalEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Do you really want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await deleteJournalEntry(entry.id);
              if (success) {
                setState(() {
                  journalEntries.remove(entry);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Journal entry deleted')),
                );
              } else {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to delete entry'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(JournalEntry entry) {
    final titleController = TextEditingController(text: entry.title);
    final descController = TextEditingController(text: entry.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Journal Entry'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Title cannot be empty')),
                  );
                  return;
                }

                final success = await updateJournalEntry(
                  id: entry.id, 
                  title: titleController.text.trim(),
                  description: descController.text.trim(),
                );

                if (success) {
                  setState(() {
                    entry.title = titleController.text.trim();
                    entry.description = descController.text.trim();
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Journal entry updated')),
                  );
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to update entry'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: entry.moodColor,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class JournalEntry {
  final String id;
  String time;
  String title;
  String description;
  final DateTime dateTime;
  final String mood;
  final Color moodColor;

  JournalEntry({
    required this.id,
    required this.time,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.mood,
    required this.moodColor,
  });
}
