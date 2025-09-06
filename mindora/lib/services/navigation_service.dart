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

  // Navigate to appointments page with appointment information
  static Future<void> navigateToAppointmentFromNotification(
    Map<String, String?> payload,
  ) async {
    if (context == null) return;

    try {
      // Extract appointment information from payload
      final patientName = payload["patient_name"] ?? "";
      final appointmentTime = payload["appointment_time"] ?? "";
      final appointmentType = payload["type"] ?? "";

      // Show a snackbar with appointment info and navigation action
      if (patientName.isNotEmpty && appointmentTime.isNotEmpty && context != null) {
        ScaffoldMessenger.of(context!).showSnackBar(
          SnackBar(
            content: Text(
              appointmentType == "appointment_reminder"
                  ? "Reminder: Appointment with $patientName at $appointmentTime"
                  : appointmentType == "appointment_starting"
                  ? "Starting now: Appointment with $patientName"
                  : "Appointment: $patientName at $appointmentTime",
            ),
            backgroundColor: const Color(0xFF4A148C),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'View Appointments',
              textColor: Colors.white,
              onPressed: () {
                // Navigate to appointments page
                // You can customize this route based on your app's navigation structure
                navigateTo('/appointments');
              },
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error handling appointment notification: $e');
    }
  }
}
