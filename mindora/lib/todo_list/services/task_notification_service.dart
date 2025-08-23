import 'package:awesome_notifications/awesome_notifications.dart';
import '../models/task_model.dart';

class TaskNotificationService {
  static Future<void> scheduleTaskDueNotification(Task task) async {
    if (task.dueDate == null) return;

    final now = DateTime.now();

    // Schedule notification for exact due time only
    if (task.dueDate!.isAfter(now)) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: task.id.hashCode,
          channelKey: 'high_importance_channel',
          title: 'Task Due Now!',
          body: 'Task "${task.title}" is now due!',
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Alarm,
          payload: {
            'task_id': task.id,
            'task_title': task.title,
            'type': 'due',
            'navigate': 'true',
          },
        ),
        schedule: NotificationCalendar(
          year: task.dueDate!.year,
          month: task.dueDate!.month,
          day: task.dueDate!.day,
          hour: task.dueDate!.hour,
          minute: task.dueDate!.minute,
          second: 0,
          millisecond: 0,
        ),
      );
    }
  }

  static Future<void> cancelTaskNotifications(String taskId) async {
    await AwesomeNotifications().cancel(taskId.hashCode);
  }

  static Future<void> showTaskCompletedNotification(Task task) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'high_importance_channel',
        title: 'Task Completed! 🎉',
        body: 'Great job completing "${task.title}"',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Status,
      ),
    );
  }

  static Future<void> checkAndNotifyOverdueTasks(List<Task> tasks) async {
    final overdueTasks = tasks.where((task) => task.isOverdue).toList();

    if (overdueTasks.isNotEmpty) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'high_importance_channel',
          title: 'Overdue Tasks',
          body: 'You have ${overdueTasks.length} overdue task(s)',
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Reminder,
        ),
      );
    }
  }
}
