import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskSuggestionPopup extends StatefulWidget {
  final List<Task> suggestions;
  final Function(List<Task>) onAcceptTasks;

  const TaskSuggestionPopup({
    Key? key,
    required this.suggestions,
    required this.onAcceptTasks,
  }) : super(key: key);

  @override
  _TaskSuggestionPopupState createState() => _TaskSuggestionPopupState();
}

class _TaskSuggestionPopupState extends State<TaskSuggestionPopup> {
  List<bool> selectedTasks = [];

  @override
  void initState() {
    super.initState();
    selectedTasks = List.filled(widget.suggestions.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: Colors.purple[600], size: 28),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'AI Wellness Suggestions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[700],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 14,
                        color: Colors.green[700],
                      ),
                      SizedBox(width: 4),
                      Text(
                        'AI',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              'Based on your mood, stress, and sleep data, here are personalized wellness tasks:',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.suggestions.length,
                  itemBuilder: (context, index) {
                    final task = widget.suggestions[index];
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedTasks[index]
                              ? Colors.purple[300]!
                              : Colors.grey[300]!,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        color: selectedTasks[index]
                            ? Colors.purple[50]
                            : Colors.grey[50],
                      ),
                      child: CheckboxListTile(
                        title: Text(
                          task.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (task.description != null)
                              Text(
                                task.description!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: task.priorityColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    task.priorityText,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: task.priorityColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                if (task.dueDate != null)
                                  Text(
                                    '${task.dueDate!.hour.toString().padLeft(2, '0')}:${task.dueDate!.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        value: selectedTasks[index],
                        onChanged: (bool? value) {
                          setState(() {
                            selectedTasks[index] = value ?? false;
                          });
                        },
                        activeColor: Colors.purple[300],
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    child: Text(
                      'Maybe Later',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Flexible(
                  child: ElevatedButton(
                    onPressed: () {
                      final selectedTaskList = <Task>[];
                      for (int i = 0; i < selectedTasks.length; i++) {
                        if (selectedTasks[i]) {
                          selectedTaskList.add(widget.suggestions[i]);
                        }
                      }
                      widget.onAcceptTasks(selectedTaskList);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[400],
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Add Selected Tasks',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
