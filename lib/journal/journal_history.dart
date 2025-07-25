import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class JournalHistoryPage extends StatefulWidget {
  const JournalHistoryPage({Key? key}) : super(key: key);

  @override
  State<JournalHistoryPage> createState() => _JournalHistoryPageState();
}

class _JournalHistoryPageState extends State<JournalHistoryPage> {
  String sortOrder = 'Newest';

  final List<JournalEntry> journalEntries = [
    JournalEntry(
      time: "10:00",
      title: "Feeling Positive Today! 😊",
      description:
          "I'm grateful for the supportive phone call I had with my best friend.",
      moodColor: Colors.green,
      dateTime: DateTime(2025, 7, 11, 10, 0),
    ),
    JournalEntry(
      time: "9:00",
      title: "I Love my Dog!",
      description:
          "I experienced pure joy today while playing with my dog in the park.",
      moodColor: Colors.orange,
      dateTime: DateTime(2025, 7, 11, 9, 0),
    ),
    JournalEntry(
      time: "8:00",
      title: "Felt Bad, but it's all OK",
      description:
          "I felt anxious today during the team meeting, but it helped stay truthful.",
      moodColor: Colors.purple,
      dateTime: DateTime(2025, 7, 11, 8, 0),
    ),
    JournalEntry(
      time: "7:00",
      title: "Felt Sad & Grief",
      description:
          "Feeling sad today after hearing a touching but heartbreaking news.",
      moodColor: Colors.blue,
      dateTime: DateTime(2025, 7, 11, 7, 0),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Sort journal entries based on the selected order
    List<JournalEntry> sortedEntries = [...journalEntries];
    sortedEntries.sort((a, b) {
      if (sortOrder == 'Newest') {
        return b.dateTime.compareTo(a.dateTime);
      } else {
        return a.dateTime.compareTo(b.dateTime);
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
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14, // Show two weeks
        itemBuilder: (context, index) {
          final date = startOfWeek.add(Duration(days: index));
          final weekday = DateFormat.E().format(date); // Mon, Tue
          final day = DateFormat.d().format(date); // 25, 26
          final isToday = date.day == now.day &&
              date.month == now.month &&
              date.year == now.year;

          return Container(
            width: 60,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: isToday ? const Color(0xFFDCB8F5) : const Color(0xFFF3E9FF),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              "$weekday\n$day",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isToday ? Colors.white : Colors.black87,
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
                  color: entry.moodColor,
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
                        onPressed: () {
                          setState(() {
                            journalEntries.remove(entry);
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                        ),
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
              onPressed: () {
                setState(() {
                  entry.title = titleController.text;
                  entry.description = descController.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

// Update JournalEntry to allow editing fields:
class JournalEntry {
  String time;
  String title;
  String description;
  final Color moodColor;
  final DateTime dateTime;

  JournalEntry({
    required this.time,
    required this.title,
    required this.description,
    required this.moodColor,
    required this.dateTime,
  });
}
