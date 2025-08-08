import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'backend.dart'; // Make sure this has fetchJournalEntries()

class JournalHistoryPage extends StatefulWidget {
  const JournalHistoryPage({super.key});

  @override
  State<JournalHistoryPage> createState() => _JournalHistoryPageState();
}

class _JournalHistoryPageState extends State<JournalHistoryPage> {
  String sortOrder = 'Newest';

  List<JournalEntry> journalEntries = [];

  DateTime? selectedDate; // Add this state variable to track the selected date

  @override
  void initState() {
    super.initState();
    _loadJournalEntries();
  }

  Future<void> _loadJournalEntries() async {
    try {
      final rawEntries = await fetchJournalEntries();

      final List<JournalEntry> loadedEntries = rawEntries.map((json) {
        final j_id = json['j_id'] ?? '';
        final time = json['time'] ?? '00:00';
        final title = json['title'] ?? 'No Title';
        final description = json['information'] ?? '';
        final dateStr = json['date'] ?? DateTime.now().toIso8601String();

        // Parse date string
        DateTime dateTime;
        try {
          dateTime = DateTime.parse(dateStr);
        } catch (_) {
          dateTime = DateTime.now();
        }

        Color moodColor = Colors.grey;

        if (json['mood_color'] != null) {
          final mc = json['mood_color'];
          if (mc is String) {
            try {
              final hexColor = mc.replaceAll('#', '');
              moodColor = Color(int.parse('FF$hexColor', radix: 16));
            } catch (_) {}
          } else if (mc is int) {
            moodColor = Color(mc);
          }
        }

       return JournalEntry(
        id: j_id,
        time: time,
        title: title,
        description: description,
        dateTime: dateTime,
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
              child: ListView.builder(
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
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7)); // Start from Sunday

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7, // Only show 7 days (Sunday to Saturday)
        itemBuilder: (context, index) {
          final date = startOfWeek.add(Duration(days: index));
          final weekday = DateFormat.E().format(date); // Day name (e.g., Sun, Mon)
          final day = DateFormat.d().format(date); // Day number (e.g., 6, 7)
          
          // Better date comparison - compare only year, month, and day
          final isSelected = selectedDate != null && 
              selectedDate!.year == date.year &&
              selectedDate!.month == date.month &&
              selectedDate!.day == date.day;

          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  selectedDate = null; // Untoggle if already selected
                } else {
                  selectedDate = DateTime(date.year, date.month, date.day); // Set selected date
                }
              });
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6A1B9A) : const Color(0xFFF3E9FF), // Much darker purple for selected
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
        color: const Color(0xFFF7F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                entry.time,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
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
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
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
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onSelected: (value) {
              if (value == 'edit') {
                _showEditDialog(entry);
              } else if (value == 'delete') {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Entry'),
                    content: const Text('Do you really want to delete this entry?'),
                    actions: [
                      ElevatedButton(
                        onPressed: () async {
                          final success = await deleteJournalEntry(entry.id);
                          if (success) {
                            setState(() {
                              journalEntries.remove(entry);
                            });
                            Navigator.pop(context); // Close the dialog
                          } else {
                            // Optionally show an error message
                            debugPrint("Failed to delete journal entry.");
                          }
                        },
                        style: ElevatedButton.styleFrom(),
                        child: const Text('Yes'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('No'),
                      ),
                    ],
                  ),
                );
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
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
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
    
    final success = await updateJournalEntry(
      id: entry.id, 
      title: titleController.text,
      description: descController.text,
    );

    if (success) {
      setState(() {
        entry.title = titleController.text;
        entry.description = descController.text;
      });
      Navigator.pop(context);
    } else {
      // Optionally show error
      debugPrint("Failed to update journal entry.");
    }
  },
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

  JournalEntry({
    required this.id,
    required this.time,
    required this.title,
    required this.description,
    required this.dateTime,
  });

}
