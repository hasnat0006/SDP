import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDF9F6),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left_sharp, color: Colors.white, size: 30),
          onPressed: () {
            // Handle back navigation
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
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "TODAY, ${dates[selectedDateIndex]}",
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                  decorationColor: Color.fromARGB(255, 209, 24, 24),
                ),
              ),
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
              SizedBox(height: 24),
              ...tasks.asMap().entries.map((entry) {
                int index = entry.key;
                String task = entry.value;
                return TaskTile(
                  task: task,
                  onChanged: (_) => markTaskComplete(index),
                  value: false,
                );
              }),
              SizedBox(height: 20),
              Text(
                "COMPLETED",
                style: TextStyle(color: Colors.brown, letterSpacing: 1),
              ),
              ...completedTasks.map(
                (task) => TaskTile(
                  task: task,
                  value: true,
                  onChanged: (_) {},
                  isCompleted: true,
                ),
              ),
              Spacer(),
              Row(
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
                          hintText: "Write a task...",
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => addTask(taskController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFD2BB7C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text("Add"),
                  ),
                ],
              ),
            ],
          ),
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

  const TaskTile({
    super.key,
    required this.task,
    required this.value,
    required this.onChanged,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.grey[100] : Colors.grey[50],
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
          Icon(Icons.drag_handle, color: Colors.grey),
        ],
      ),
    );
  }
}
