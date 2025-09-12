import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class RealTimeNotificationService {
  static StreamSubscription? _appointmentSubscription;
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Show appointment accepted notification
  static Future<void> showAppointmentAcceptedNotification({
    required String doctorName,
    required String appointmentDate,
    required String appointmentTime,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'high_importance_channel',
        title: '🎉 Appointment Accepted',
        body:
            'Your appointment with Dr. $doctorName on $appointmentDate at $appointmentTime has been accepted!',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Status,
        payload: {
          'type': 'appointment_accepted',
          'navigate': 'true',
          'page': 'appointment_details',
          'doctor_name': doctorName,
          'date': appointmentDate,
          'time': appointmentTime,
        },
      ),
    );
    print('✅ Real-time appointment accepted notification sent');
  }

  /// Show appointment rejected notification
  static Future<void> showAppointmentRejectedNotification({
    required String doctorName,
    required String appointmentDate,
    required String appointmentTime,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'high_importance_channel',
        title: '❌ Appointment Rejected',
        body:
            'Your appointment with Dr. $doctorName on $appointmentDate at $appointmentTime has been rejected.',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Status,
        payload: {
          'type': 'appointment_rejected',
          'navigate': 'true',
          'page': 'appointment_details',
          'doctor_name': doctorName,
          'date': appointmentDate,
          'time': appointmentTime,
        },
      ),
    );
    print('✅ Real-time appointment rejected notification sent');
  }

  /// Subscribe to real-time appointment updates for a specific user
  static void subscribeToAppointmentUpdates(String userId) {
    print('🔔 Subscribing to appointment updates for user: $userId');

    // Cancel any existing subscription
    _appointmentSubscription?.cancel();

    try {
      _appointmentSubscription = _supabase
          .from('appointments')
          .stream(primaryKey: ['app_id'])
          .eq('user_id', userId)
          .listen((List<Map<String, dynamic>> data) {
            print('📡 Received appointment update: $data');

            for (final appointment in data) {
              _handleAppointmentUpdate(appointment);
            }
          });

      print('✅ Successfully subscribed to appointment updates');
    } catch (e) {
      print('❌ Error subscribing to appointment updates: $e');
    }
  }

  /// Handle individual appointment updates
  static void _handleAppointmentUpdate(Map<String, dynamic> appointment) {
    final status = appointment['status']?.toString();
    final doctorName = appointment['doctor_name']?.toString() ?? 'Doctor';
    final date = appointment['date']?.toString() ?? 'Unknown Date';
    final time = appointment['time']?.toString() ?? 'Unknown Time';

    print(
      '🔍 Processing appointment update - Status: $status, Doctor: $doctorName',
    );

    switch (status) {
      case 'Confirmed':
        showAppointmentAcceptedNotification(
          doctorName: doctorName,
          appointmentDate: date,
          appointmentTime: time,
        );
        break;
      case 'Cancelled':
        showAppointmentRejectedNotification(
          doctorName: doctorName,
          appointmentDate: date,
          appointmentTime: time,
        );
        break;
      default:
        print('📝 Appointment status "$status" - no notification needed');
        break;
    }
  }

  /// Unsubscribe from appointment updates
  static void unsubscribeFromAppointmentUpdates() {
    print('🔕 Unsubscribing from appointment updates');
    _appointmentSubscription?.cancel();
    _appointmentSubscription = null;
  }

  /// Initialize real-time notifications for a user (call this when user logs in)
  static void initializeForUser(String userId) {
    print('🚀 Initializing real-time notifications for user: $userId');
    subscribeToAppointmentUpdates(userId);
  }

  /// Clean up resources (call this when user logs out or app is disposed)
  static void dispose() {
    print('🧹 Disposing real-time notification service');
    unsubscribeFromAppointmentUpdates();
  }
}
