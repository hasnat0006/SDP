import 'dart:convert';
import '../backend/main_query.dart';
import 'package:http/http.dart'
    as http; // Import the method to interact with the backend

// Function to book an appointment
Future<void> bookAppointment({
  required String docId,
  required String userId,
  required String name,
  required String institution,
  required String date,
  required String time,
  required String reason,
  required String email,
}) async {
  // Prepare data for appointment
  final Map<String, dynamic> appointmentData = {
    'docId': docId,
    'userId': userId,
    'name': name,
    'institution': institution,
    'date': date,
    'time': time,
    'reason': reason,
    'email': email.isEmpty ? '' : email, // Handle empty email
  };

  try {
    // Call the backend API to book the appointment
    await postToBackend('booked', appointmentData);
    print('✅ Appointment booked for user: $userId');
  } catch (e) {
    print('❌ Error booking appointment: $e');
    rethrow;
  }
}

// Function to get therapist

Future<List<dynamic>> GetTherapist() async {
  try {
    // Call the existing function to fetch therapist data
    final data = await postToBackend('therapists', {});

    // Ensure that the response is a list, otherwise wrap it into a lis
    // If it's a single map (single therapist), wrap it into a list
    print('✅ Single therapist data fetched');
    return data; // Return the map wrapped in a list
  } catch (e) {
    print('❌ Error: $e');
    rethrow; // Rethrow the error to be handled elsewhere
  }
}
