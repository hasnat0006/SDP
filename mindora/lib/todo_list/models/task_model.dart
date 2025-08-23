import 'package:flutter/material.dart';

enum TaskPriority { low, medium, high, critical }

class Task {
  String id;
  String title;
  String? description;
  DateTime? dueDate;
  TaskPriority priority;
  bool isCompleted;
  DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Check if task is overdue
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  // Get priority color
  Color get priorityColor {
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

  // Get priority text
  String get priorityText {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.critical:
        return 'Critical';
    }
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority.toString().split('.').last, // Convert enum to string
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'])
          : (json['duedate'] != null ? DateTime.parse(json['duedate']) : null),
      priority: _parsePriority(json['priority']),
      isCompleted: json['isCompleted'] ?? json['iscompleted'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : (json['createdat'] != null
                ? DateTime.parse(json['createdat'])
                : DateTime.now()),
    );
  } // Helper method to parse priority from different formats
  static TaskPriority _parsePriority(dynamic priority) {
    if (priority is int) {
      if (priority >= 0 && priority < TaskPriority.values.length) {
        return TaskPriority.values[priority];
      }
    } else if (priority is String) {
      switch (priority.toLowerCase()) {
        case 'low':
          return TaskPriority.low;
        case 'medium':
          return TaskPriority.medium;
        case 'high':
          return TaskPriority.high;
        case 'critical':
          return TaskPriority.critical;
      }
    }
    return TaskPriority.medium; // default
  }

  // Copy with method for updates
  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
