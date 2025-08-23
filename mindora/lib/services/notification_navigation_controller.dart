import 'package:flutter/material.dart';

class NotificationNavigationController {
  static final NotificationNavigationController _instance =
      NotificationNavigationController._internal();
  factory NotificationNavigationController() => _instance;
  NotificationNavigationController._internal();

  // Stream controller to communicate navigation requests
  final ValueNotifier<TaskNavigationRequest?> _navigationRequest =
      ValueNotifier<TaskNavigationRequest?>(null);

  ValueNotifier<TaskNavigationRequest?> get navigationRequest =>
      _navigationRequest;

  // Request navigation to tasks tab with task information
  void requestTaskNavigation({
    required String taskId,
    required String taskTitle,
    required String type,
  }) {
    _navigationRequest.value = TaskNavigationRequest(
      taskId: taskId,
      taskTitle: taskTitle,
      type: type,
      timestamp: DateTime.now(),
    );
  }

  // Clear the navigation request after it's been handled
  void clearNavigationRequest() {
    _navigationRequest.value = null;
  }

  void dispose() {
    _navigationRequest.dispose();
  }
}

class TaskNavigationRequest {
  final String taskId;
  final String taskTitle;
  final String type;
  final DateTime timestamp;

  TaskNavigationRequest({
    required this.taskId,
    required this.taskTitle,
    required this.type,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'TaskNavigationRequest(taskId: $taskId, taskTitle: $taskTitle, type: $type, timestamp: $timestamp)';
  }
}
