# Real-Time Appointment Notifications Setup

## Overview

This system provides real-time notifications to users when their appointments are accepted or rejected by therapists using Supabase Realtime.

## How it Works

1. **Database Changes**: When a therapist accepts/rejects an appointment, the `status` field in the `appointments` table is updated to 'Confirmed' or 'Cancelled'.

2. **Real-Time Listening**: The user's app listens for changes in the `appointments` table using Supabase Realtime.

3. **Local Notifications**: When a status change is detected, a local notification is shown using AwesomeNotifications.

## Implementation Details

### Files Created/Modified:

- `lib/appointment/service/realtimenotification.dart` - Main real-time notification service
- `lib/services/notification_manager.dart` - Manages notification lifecycle
- `lib/main.dart` - Initialize notifications on app start
- `lib/login/signup/login.dart` - Reinitialize on login
- `lib/utils/app_utils.dart` - Dispose on logout

### Key Functions:

#### RealTimeNotificationService

- `subscribeToAppointmentUpdates(userId)` - Subscribe to appointment changes
- `showAppointmentAcceptedNotification()` - Show acceptance notification
- `showAppointmentRejectedNotification()` - Show rejection notification
- `dispose()` - Clean up subscriptions

#### NotificationManager

- `initialize()` - Initialize for current user
- `reinitialize()` - Reinitialize after login
- `dispose()` - Clean up on logout

## Usage

### For Users (Patients)

No action required - notifications are automatically set up when logged in.

### For Therapists

When accepting/rejecting appointments, the system automatically:

1. Updates the appointment status in the database
2. Triggers real-time notifications to the patient

## Database Requirements

Make sure your `appointments` table has:

- `user_id` (UUID) - Patient's user ID
- `status` (text) - 'Pending', 'Confirmed', 'Cancelled'
- `doctor_name` (text) - Therapist's name
- `date` (text) - Appointment date
- `time` (text) - Appointment time

## Supabase Realtime Setup

Ensure Realtime is enabled for the `appointments` table in your Supabase dashboard:

1. Go to Database > Replication
2. Add the `appointments` table to realtime publication

## Testing

To test the notifications:

1. Log in as a user (patient)
2. Book an appointment with a therapist
3. Log in as the therapist
4. Accept/reject the appointment
5. The user should receive a real-time notification

## Troubleshooting

- Check that Supabase Realtime is enabled for the appointments table
- Verify the user has notification permissions
- Check console logs for error messages
- Ensure the appointment status values match exactly ('Confirmed', 'Cancelled')
