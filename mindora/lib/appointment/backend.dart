import '../backend/main_query.dart';

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

    // The postToBackend wraps the response in an array, but therapists endpoint already returns an array
    // So we need to extract the actual array from the wrapped array
    if (data.isNotEmpty && data[0] is List) {
      print('✅ Therapist data fetched and unwrapped');
      return data[0]; // Return the actual therapist array
    } else {
      print('✅ Single therapist data fetched');
      return data; // Return as is if it's not wrapped
    }
  } catch (e) {
    print('❌ Error: $e');
    rethrow; // Rethrow the error to be handled elsewhere
  }
}

Future<List<dynamic>> GetAppointments(String userId) async {
  try {
    final data = await getFromBackend('yourappt/$userId');

    if (data is List) {
      print('✅ Appointment data fetched');
      return data; // Return the appointment array directly
    } else {
      print('✅ Single appointment data fetched');
      return [data]; // Wrap single item in array
    }
  } catch (e) {
    print('❌ Error: $e');
    rethrow;
  }
}
