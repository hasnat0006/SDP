import 'package:flutter/material.dart';
import '../dashboard/p_dashboard.dart'; // <-- Add this import

class ToDoApp extends StatelessWidget {
  const ToDoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: ToDoPage(), debugShowCheckedModeBanner: false);
  }
}

class ToDoPage extends StatefulWidget {
  const ToDoPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ToDoPageState createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  final List<String> dates = [
    '28',
    '29',
    '30',
    '31',
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
  ];
  final List<String> days = [
    'SAT',
    'SUN',
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
    'SUN',
    'MON',
  ];
  int selectedDateIndex = 1;

  List<String> tasks = [
    "Drink 8 glasses of water",
    "Go for a 30-minute walk",
    "Write in thought journal",
  ];

  List<String> completedTasks = [
    "Practice deep breathing exercises",
    "Plan meals for the day",
  ];

  final TextEditingController taskController = TextEditingController();

  void addTask(String task) {
    if (task.isNotEmpty) {
      setState(() {
        tasks.add(task);
        taskController.clear();
      });
    }
  }

  void markTaskComplete(int index) {
    setState(() {
      completedTasks.add(tasks[index]);
      tasks.removeAt(index);
    });
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  void deleteCompletedTask(int index) {
    setState(() {
      completedTasks.removeAt(index);
    });
  }

  void editTask(int index) {
    final TextEditingController editController = TextEditingController(
      text: tasks[index],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Task'),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(
              hintText: 'Enter task title',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (editController.text.isNotEmpty) {
                  setState(() {
                    tasks[index] = editController.text;
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDF9F6),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left_sharp, color: Colors.white, size: 30),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const DashboardPage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(-1.0, 0.0); // Slide from left to right
                  const end = Offset.zero;
                  const curve = Curves.ease;
                  final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              ),
            );
          },
        ),
        title: Text(
          'Task',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        backgroundColor: Color(0xFFD39AD5),
        centerTitle: true,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SizedBox(
                        height: 80,

                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          // padding: EdgeInsets.zero,
                          itemCount: days.length,
                          padding: EdgeInsets.symmetric(horizontal: 5),

                          itemBuilder: (context, index) {
                            final isSelected = index == selectedDateIndex;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedDateIndex = index;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      days[index],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.purple[200]
                                            : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          dates[index],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 8),
                    Text(
                      "Task remaining (${tasks.length})",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.purple[400],
                        decorationColor: Color.fromARGB(255, 209, 24, 24),
                      ),
                    ),
                    SizedBox(height: 8),

                    ...tasks.asMap().entries.map((entry) {
                      int index = entry.key;
                      String task = entry.value;
                      return TaskTile(
                        task: task,
                        onChanged: (_) => markTaskComplete(index),
                        value: false,
                        onEdit: () => editTask(index),
                        onDelete: () => deleteTask(index),
                      );
                    }),
                    SizedBox(height: 20),
                    Text(
                      "Completed (${completedTasks.length})",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.purple[400],
                        decorationColor: Color.fromARGB(255, 209, 24, 24),
                      ),
                    ),
                    ...completedTasks.asMap().entries.map((entry) {
                      int index = entry.key;
                      String task = entry.value;
                      return TaskTile(
                        task: task,
                        value: true,
                        onChanged: (_) {},
                        isCompleted: true,
                        onDelete: () => deleteCompletedTask(index),
                      );
                    }),
                  ],
                ),
              ),
            ),
            // Fixed bottom input area
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFFFDF9F6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: taskController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Add new task...",
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => addTask(taskController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Add",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        decorationColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskTile extends StatelessWidget {
  final String task;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final bool isCompleted;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.value,
    required this.onChanged,
    this.isCompleted = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.grey[100] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),

      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.grey,
          ),
          Expanded(
            child: Text(
              task,
              style: TextStyle(
                color: isCompleted ? Colors.grey : Colors.black,
                decoration: isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
          Transform.rotate(
            angle: 1.5708, // 90 degrees in radians
            child: _buildPopupMenu(),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupMenu() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz, color: Colors.grey),
      onSelected: (String value) {
        switch (value) {
          case 'edit_title':
            if (onEdit != null) onEdit!();
            break;
          case 'edit_details':
            if (onEdit != null) onEdit!();
            break;
          case 'update_date':
            // Handle date update
            break;
          case 'delete':
            if (onDelete != null) onDelete!();
            break;
        }
      },
      itemBuilder: (BuildContext context) => _buildPopupMenuItems(),
    );
  }

  List<PopupMenuEntry<String>> _buildPopupMenuItems() {
    return <PopupMenuEntry<String>>[
      PopupMenuItem<String>(
        value: 'edit_title',
        child: _buildMenuItem(Icons.edit, 'Edit Title', Colors.grey[600]),
      ),
      PopupMenuItem<String>(
        value: 'edit_details',
        child: _buildMenuItem(
          Icons.description,
          'Edit Details',
          Colors.grey[600],
        ),
      ),
      PopupMenuItem<String>(
        value: 'update_date',
        child: _buildMenuItem(
          Icons.calendar_today,
          'Update Date',
          Colors.grey[600],
        ),
      ),
      PopupMenuItem<String>(
        value: 'delete',
        child: _buildMenuItem(
          Icons.delete,
          'Delete',
          Colors.red[400],
          isDestructive: true,
        ),
      ),
    ];
  }

  Widget _buildMenuItem(
    IconData icon,
    String text,
    Color? color, {
    bool isDestructive = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: 8),
        Text(text, style: TextStyle(color: isDestructive ? color : null)),
      ],
    );
  }
}
