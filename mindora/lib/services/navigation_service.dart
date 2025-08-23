import 'package:flutter/material.dart';
import 'notification_navigation_controller.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static GlobalKey<NavigatorState> get key => navigatorKey;

  static BuildContext? get context => navigatorKey.currentContext;

  // Navigate to a specific route
  static Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  // Navigate and replace current route
  static Future<dynamic> navigateToAndReplace(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  // Navigate and clear all previous routes
  static Future<dynamic> navigateToAndClearAll(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  // Go back
  static void goBack({dynamic result}) {
    return navigatorKey.currentState!.pop(result);
  }

  // Navigate to tasks page with task information
  static Future<void> navigateToTaskFromNotification(
    Map<String, String?> payload,
  ) async {
    if (context == null) return;

    try {
      // Extract task information from payload
      final taskId = payload["task_id"] ?? "";
      final taskTitle = payload["task_title"] ?? "";
      final taskType = payload["type"] ?? "";

      // Use the notification navigation controller to request navigation
      final controller = NotificationNavigationController();
      controller.requestTaskNavigation(
        taskId: taskId,
        taskTitle: taskTitle,
        type: taskType,
      );

      // Show a snackbar with task info and navigation action
      if (taskTitle.isNotEmpty && taskType.isNotEmpty && context != null) {
        ScaffoldMessenger.of(context!).showSnackBar(
          SnackBar(
            content: Text(
              taskType == "reminder"
                  ? "Reminder: $taskTitle"
                  : taskType == "due"
                  ? "Due now: $taskTitle"
                  : "Task: $taskTitle",
            ),
            backgroundColor: const Color(0xFF4A148C),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'View Tasks',
              textColor: Colors.white,
              onPressed: () {
                // Request navigation to tasks again to trigger the navigation
                controller.requestTaskNavigation(
                  taskId: taskId,
                  taskTitle: taskTitle,
                  type: taskType,
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error handling task notification: $e');
    }
  }
}
