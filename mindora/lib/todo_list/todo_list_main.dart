import 'package:client/navbar/navbar.dart';
import 'package:flutter/material.dart';
// <-- Add this import

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
  List<DateTime> dateList = [];
  List<String> daysList = [];
  int selectedDateIndex = 7; // Start from the middle (current date)

  List<Task> tasks = [];
  List<Task> completedTasks = [];
  bool hasShownSuggestions = false;

  @override
  void initState() {
    super.initState();
    _generateDateList();
    _loadTasks();
    _checkForTaskSuggestions();
    _scheduleNotificationCheck();
  }

  void _generateDateList() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Generate 15 days: 7 days before today, today, and 7 days after today
    dateList.clear();
    daysList.clear();

    for (int i = -7; i <= 7; i++) {
      final date = today.add(Duration(days: i));
      dateList.add(date);

      // Get day name
      const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      daysList.add(dayNames[date.weekday - 1]);
    }
  }

  // Get tasks for the selected date
  List<Task> getTasksForSelectedDate() {
    if (selectedDateIndex < 0 || selectedDateIndex >= dateList.length) {
      return tasks;
    }

    final selectedDate = dateList[selectedDateIndex];
    return tasks.where((task) {
      if (task.dueDate == null) {
        // Tasks without due date are shown on current day (today)
        return selectedDateIndex == 7;
      }

      final taskDate = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );

      return taskDate == selectedDate;
    }).toList();
  }

  // Get completed tasks for the selected date
  List<Task> getCompletedTasksForSelectedDate() {
    if (selectedDateIndex < 0 || selectedDateIndex >= dateList.length) {
      return completedTasks;
    }

    final selectedDate = dateList[selectedDateIndex];
    return completedTasks.where((task) {
      if (task.dueDate == null) {
        // Tasks without due date are shown on current day (today)
        return selectedDateIndex == 7;
      }

      final taskDate = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );

      return taskDate == selectedDate;
    }).toList();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksString = prefs.getString('tasks') ?? '[]';
    final completedTasksString = prefs.getString('completed_tasks') ?? '[]';

    final tasksJson = json.decode(tasksString) as List;
    final completedTasksJson = json.decode(completedTasksString) as List;

    setState(() {
      tasks = tasksJson.map((json) => Task.fromJson(json)).toList();
      completedTasks = completedTasksJson
          .map((json) => Task.fromJson(json))
          .toList();
    });
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksString = json.encode(
      tasks.map((task) => task.toJson()).toList(),
    );
    final completedTasksString = json.encode(
      completedTasks.map((task) => task.toJson()).toList(),
    );

    await prefs.setString('tasks', tasksString);
    await prefs.setString('completed_tasks', completedTasksString);
  }

  Future<void> _checkForTaskSuggestions() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSuggestionDate = prefs.getString('last_suggestion_date');
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (lastSuggestionDate != today && !hasShownSuggestions) {
      setState(() {
        hasShownSuggestions = true;
      });

      // Show suggestions after a short delay
      Future.delayed(Duration(milliseconds: 1000), () {
        _showTaskSuggestions();
      });

      await prefs.setString('last_suggestion_date', today);
    }
  }

  void _scheduleNotificationCheck() {
    // Check for overdue tasks every hour
    Future.delayed(Duration(hours: 1), () {
      TaskNotificationService.checkAndNotifyOverdueTasks(tasks);
      _scheduleNotificationCheck();
    });
  }

  void _showTaskSuggestions() {
    final suggestions = TaskSuggestionService.getPersonalizedSuggestions(
      userMood: 'neutral', // You can get this from user data
      stressLevel: 5, // You can get this from user data
    );

    showDialog(
      context: context,
      builder: (context) => TaskSuggestionPopup(
        suggestions: suggestions,
        onAcceptTasks: (selectedTasks) {
          setState(() {
            tasks.addAll(selectedTasks);
          });
          _saveTasks();

          // Schedule notifications for tasks with due dates
          for (final task in selectedTasks) {
            if (task.dueDate != null) {
              TaskNotificationService.scheduleTaskReminder(task);
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${selectedTasks.length} task(s) added successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void addTask(Task task) {
    setState(() {
      tasks.add(task);
    });
    _saveTasks();

    // Schedule notification if task has due date
    if (task.dueDate != null) {
      TaskNotificationService.scheduleTaskReminder(task);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task added successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void markTaskComplete(int index) {
    final task = tasks[index];
    final completedTask = task.copyWith(isCompleted: true);

    setState(() {
      completedTasks.add(completedTask);
      tasks.removeAt(index);
    });
    _saveTasks();

    // Cancel notifications for completed task
    TaskNotificationService.cancelTaskNotifications(task.id);

    // Show completion notification
    TaskNotificationService.showTaskCompletedNotification(task);
  }

  void deleteTask(int index) {
    final task = tasks[index];
    setState(() {
      tasks.removeAt(index);
    });
    _saveTasks();

    // Cancel notifications for deleted task
    TaskNotificationService.cancelTaskNotifications(task.id);
  }

  void deleteCompletedTask(int index) {
    setState(() {
      completedTasks.removeAt(index);
    });
    _saveTasks();
  }

  void editTask(int index) {
    final task = tasks[index];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddTaskDialog(
          existingTask: task, // Pass the existing task for editing
          onTaskAdded: (updatedTask) {
            // Cancel old notifications
            TaskNotificationService.cancelTaskNotifications(task.id);

            // Update task with same ID
            final newTask = updatedTask.copyWith(id: task.id);
            setState(() {
              tasks[index] = newTask;
            });
            _saveTasks();

            // Schedule new notifications if needed
            if (newTask.dueDate != null) {
              TaskNotificationService.scheduleTaskReminder(newTask);
            }
          },
        );
      },
    );
  }

  void _showAddTaskDialog() {
    // Create a task with the selected date as the default due date
    Task? defaultTask;
    if (selectedDateIndex >= 0 && selectedDateIndex < dateList.length) {
      final selectedDate = dateList[selectedDateIndex];
      // Set default due time to end of day
      final defaultDueDate = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        23,
        59,
      );
      defaultTask = Task(id: '', title: '', dueDate: defaultDueDate);
    }

    showDialog(
      context: context,
      builder: (context) =>
          AddTaskDialog(onTaskAdded: addTask, existingTask: defaultTask),
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
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const MainNavBar(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      const begin = Offset(
                        -1.0,
                        0.0,
                      ); // Slide from left to right
                      const end = Offset.zero;
                      const curve = Curves.ease;
                      final tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
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
        backgroundColor: Color(0xFFD1A1E3),
        centerTitle: true,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
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
                          itemCount: daysList.length,
                          padding: EdgeInsets.symmetric(horizontal: 5),

                          itemBuilder: (context, index) {
                            final isSelected = index == selectedDateIndex;
                            final isToday = index == 7; // Today is at index 7
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
                                      daysList[index],
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
                                            : isToday
                                            ? Colors.blue[100]
                                            : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(10),
                                        border: isToday && !isSelected
                                            ? Border.all(
                                                color: Colors.blue,
                                                width: 2,
                                              )
                                            : null,
                                      ),
                                      child: Center(
                                        child: Text(
                                          dateList[index].day.toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? Colors.white
                                                : isToday
                                                ? Colors.blue[700]
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
                    Row(
                      children: [
                        Text(
                          "Task remaining (",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.purple[400],
                          ),
                        ),
                        Text(
                          "${getTasksForSelectedDate().length}",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[600],
                          ),
                        ),
                        Text(
                          ")",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.purple[400],
                          ),
                        ),
                        Spacer(),
                        Text(
                          selectedDateIndex == 7
                              ? "Today"
                              : "${dateList[selectedDateIndex].day}/${dateList[selectedDateIndex].month}",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),

                    ...getTasksForSelectedDate().asMap().entries.map((entry) {
                      Task task = entry.value;
                      // Find the actual index in the main tasks list
                      int actualIndex = tasks.indexOf(task);
                      return ImprovedTaskTile(
                        task: task,
                        onChanged: (_) => markTaskComplete(actualIndex),
                        onEdit: () => editTask(actualIndex),
                        onDelete: () => deleteTask(actualIndex),
                      );
                    }),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          "Completed (",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.purple[400],
                          ),
                        ),
                        Text(
                          "${getCompletedTasksForSelectedDate().length}",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[600],
                          ),
                        ),
                        Text(
                          ")",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.purple[400],
                          ),
                        ),
                      ],
                    ),
                    ...getCompletedTasksForSelectedDate().asMap().entries.map((
                      entry,
                    ) {
                      Task task = entry.value;
                      // Find the actual index in the main completed tasks list
                      int actualIndex = completedTasks.indexOf(task);
                      return ImprovedTaskTile(
                        task: task,
                        onChanged: (_) {},
                        onDelete: () => deleteCompletedTask(actualIndex),
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
                    child: ElevatedButton.icon(
                      onPressed: _showAddTaskDialog,
                      icon: Icon(Icons.add, color: Colors.white),
                      label: Text(
                        "Add New Task",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD1A1E3),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _showTaskSuggestions,
                    icon: Icon(Icons.lightbulb_outline, color: Colors.white),
                    label: Text(
                      "Suggestions",
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[600],
                      padding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
