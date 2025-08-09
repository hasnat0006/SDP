import 'package:flutter/material.dart';
import '../models/task_model.dart';

class AddTaskDialog extends StatefulWidget {
  final Function(Task) onTaskAdded;
  final Task? existingTask; // Add this parameter for editing

  const AddTaskDialog({
    Key? key,
    required this.onTaskAdded,
    this.existingTask, // Optional existing task for editing
  }) : super(key: key);

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  TaskPriority selectedPriority = TaskPriority.medium;
  DateTime? selectedDueDate;
  TimeOfDay? selectedDueTime;

  @override
  void initState() {
    super.initState();
    // Pre-populate fields if editing an existing task
    if (widget.existingTask != null) {
      final task = widget.existingTask!;
      titleController.text = task.title;
      descriptionController.text = task.description ?? '';
      selectedPriority = task.priority;
      selectedDueDate = task.dueDate != null
          ? DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day)
          : null;
      selectedDueTime = task.dueDate != null
          ? TimeOfDay(hour: task.dueDate!.hour, minute: task.dueDate!.minute)
          : null;
    }
  }

  bool get isEditing =>
      widget.existingTask != null && widget.existingTask!.title.isNotEmpty;

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit Task' : 'Add New Task',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[700],
                ),
              ),
              SizedBox(height: 20),

              // Title input
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Task Title*',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.purple[400]!),
                  ),
                ),
              ),
              SizedBox(height: 15),

              // Description input
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.purple[400]!),
                  ),
                ),
              ),
              SizedBox(height: 15),

              // Priority selection
              Text(
                'Priority Level',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: TaskPriority.values.map((priority) {
                    return RadioListTile<TaskPriority>(
                      title: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getPriorityColor(priority),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(_getPriorityText(priority)),
                        ],
                      ),
                      value: priority,
                      groupValue: selectedPriority,
                      onChanged: (TaskPriority? value) {
                        setState(() {
                          selectedPriority = value!;
                        });
                      },
                      activeColor: Colors.purple[400],
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 15),

              // Due date and time selection
              Text(
                'Due Date & Time (Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectDate,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.purple[400],
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              selectedDueDate != null
                                  ? '${selectedDueDate!.day}/${selectedDueDate!.month}/${selectedDueDate!.year}'
                                  : 'Select Date',
                              style: TextStyle(
                                color: selectedDueDate != null
                                    ? Colors.black
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: selectedDueDate != null ? _selectTime : null,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: selectedDueDate != null
                                  ? Colors.purple[400]
                                  : Colors.grey[400],
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              selectedDueTime != null
                                  ? '${selectedDueTime!.hour.toString().padLeft(2, '0')}:${selectedDueTime!.minute.toString().padLeft(2, '0')}'
                                  : 'Select Time',
                              style: TextStyle(
                                color: selectedDueTime != null
                                    ? Colors.black
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              if (selectedDueDate != null)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 16),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'You\'ll receive a notification 1 hour before the due time',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 25),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _addTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[400],
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      isEditing ? 'Update Task' : 'Add Task',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.purple[400]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDueDate) {
      setState(() {
        selectedDueDate = picked;
        selectedDueTime = null; // Reset time when date changes
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.purple[400]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDueTime) {
      setState(() {
        selectedDueTime = picked;
      });
    }
  }

  void _addTask() {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a task title'),
          backgroundColor: Colors.red[400],
        ),
      );
      return;
    }

    DateTime? finalDueDate;
    if (selectedDueDate != null) {
      finalDueDate = selectedDueDate!;
      if (selectedDueTime != null) {
        finalDueDate = DateTime(
          selectedDueDate!.year,
          selectedDueDate!.month,
          selectedDueDate!.day,
          selectedDueTime!.hour,
          selectedDueTime!.minute,
        );
      } else {
        // Default to end of day if no time is selected
        finalDueDate = DateTime(
          selectedDueDate!.year,
          selectedDueDate!.month,
          selectedDueDate!.day,
          23,
          59,
        );
      }
    }

    final task = Task(
      id: isEditing
          ? widget.existingTask!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      title: titleController.text.trim(),
      description: descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
      priority: selectedPriority,
      dueDate: finalDueDate,
    );

    widget.onTaskAdded(task);
    Navigator.of(context).pop();
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.critical:
        return Colors.purple;
    }
  }

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Low Priority';
      case TaskPriority.medium:
        return 'Medium Priority';
      case TaskPriority.high:
        return 'High Priority';
      case TaskPriority.critical:
        return 'Critical';
    }
  }
}
