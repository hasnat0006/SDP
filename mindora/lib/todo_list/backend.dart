import 'package:client/backend/main_query.dart';
import 'package:client/todo_list/models/task_model.dart';

class TaskBackend {
  Future<List<Task>> fetchTasks(String userId) async {
    final response = await getFromBackend('tasks/get-tasks?user_id=$userId');
    print('Fetched tasks for user $userId: $response');
    return (response as List<dynamic>)
        .map((data) => Task.fromJson(data as Map<String, dynamic>))
        .toList();
  }

  Future<Task> addTask(String userId, Task task) async {
    final response = await postToBackend('tasks/add-task', {
      'user_id': userId,
      'title': task.title,
      'description': task.description,
      'priority': task.priority
          .toString()
          .split('.')
          .last, // Convert enum to string
      'dueDate': task.dueDate?.toIso8601String(),
      'createdAt': task.createdAt.toIso8601String(), // Send client timezone
    });
    print('Added task: $response');
    return Task.fromJson(response);
  }

  Future<void> updateTask(String userId, Task task) async {
    await postToBackend('tasks/update-task', {
      'user_id': userId,
      'task_id': task.id,
      'title': task.title,
      'description': task.description,
      'priority': task.priority
          .toString()
          .split('.')
          .last, // Convert enum to string
      'due_date': task.dueDate?.toIso8601String(),
    });
    print('Updated task: ${task.id}');
    return;
  }

  Future<void> deleteTask(String userId, String taskId) async {
    await postToBackend('tasks/delete-task', {
      'user_id': userId,
      'task_id': taskId,
    });
    print('Deleted task: $taskId');
    return;
  }

  Future<void> completeTask(String userId, String taskId) async {
    await postToBackend('tasks/complete-task', {
      'user_id': userId,
      'task_id': taskId,
    });
    print('Completed task: $taskId');
    return;
  }

  Future<List<Task>> getWellnessBasedSuggestions(String userId) async {
    try {
      final response = await getFromBackend(
        'suggested-tasks/wellness?user_id=$userId',
      );
      print('Fetched wellness suggestions for user $userId: $response');

      if (response['success'] == true && response['suggestions'] != null) {
        return (response['suggestions'] as List<dynamic>)
            .map((data) => Task.fromJson(data as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to get wellness suggestions');
      }
    } catch (error) {
      print('Error fetching wellness suggestions: $error');
      // Return empty list if API fails, fallback will be handled in the service
      return [];
    }
  }

  Future<Map<String, int>> getTaskStatistics(String userId) async {
    try {
      final allTasks = await fetchTasks(userId);
      final totalTasks = allTasks.length;
      final completedTasks = allTasks.where((task) => task.isCompleted).length;

      return {'total': totalTasks, 'completed': completedTasks};
    } catch (error) {
      print('Error fetching task statistics: $error');
      return {'total': 0, 'completed': 0};
    }
  }

  Future<List<Task>> addMultipleTasks(String userId, List<Task> tasks) async {
    try {
      // Prepare tasks data for bulk insert
      final tasksData = tasks
          .map(
            (task) => {
              'title': task.title,
              'description': task.description,
              'priority': task.priority.toString().split('.').last,
              'dueDate': task.dueDate?.toIso8601String(),
              'createdAt': DateTime.now().toIso8601String(),
            },
          )
          .toList();

      final response = await postToBackend('tasks/add-multiple-tasks', {
        'user_id': userId,
        'tasks': tasksData,
      });

      print('Bulk task addition response: $response');

      if (response['success'] == true && response['added'] != null) {
        final addedTasks = (response['added'] as List<dynamic>)
            .map((data) => Task.fromJson(data as Map<String, dynamic>))
            .toList();

        if (response['errors'] != null &&
            (response['errors'] as List).isNotEmpty) {
          print('Some tasks had errors: ${response['errors']}');
        }

        print('Successfully added ${addedTasks.length} tasks via bulk insert');
        return addedTasks;
      } else {
        throw Exception('Failed to add multiple tasks');
      }
    } catch (error) {
      print(
        'Error in bulk task addition, falling back to individual adds: $error',
      );

      // Fallback to individual task addition
      List<Task> addedTasks = [];

      for (Task task in tasks) {
        try {
          // Create a new task without the suggestion ID to let database generate new ID
          final taskToAdd = Task(
            id: '', // Let database generate ID
            title: task.title,
            description: task.description,
            priority: task.priority,
            dueDate: task.dueDate,
            createdAt: DateTime.now(), // Use current time
          );

          final addedTask = await addTask(userId, taskToAdd);
          addedTasks.add(addedTask);
          print('Successfully added suggested task: ${addedTask.title}');
        } catch (taskError) {
          print('Error adding task "${task.title}": $taskError');
          // Continue with other tasks even if one fails
        }
      }

      return addedTasks;
    }
  }
}
