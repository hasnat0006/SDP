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
                Icon(Icons.lightbulb, color: Colors.amber, size: 28),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Suggested Tasks for Today',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[700],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              'Based on your profile, here are some tasks we recommend for today:',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            Container(
              height: 300,
              child: ListView.builder(
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
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Text(
                    'Maybe Later',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton(
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
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Add Selected Tasks',
                    style: TextStyle(color: Colors.white),
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
