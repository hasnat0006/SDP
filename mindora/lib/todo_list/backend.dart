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
}
