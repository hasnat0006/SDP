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
    print('🔍 Fetching appointments for user: $userId');
    // Use getFromBackend instead of postToBackend for fetching data
    final data = await getFromBackend('appointments/$userId');
    print('📦 Raw appointments data: $data');
    return data is List ? data : [];
  } catch (e) {
    print('❌ Error fetching appointments: $e');
    return [];
  }
}

// Update the cancelAppointment function
Future<bool> cancelAppointment(String appointmentId) async {
  try {
    print('🔄 Cancelling appointment: $appointmentId');

    // Send the appointmentId in the request body instead of URL params
    final response = await postToBackend('cancel-appointment', {
      'appointmentId': appointmentId,
    });

    print('📦 Cancel response: $response');
    return true;
  } catch (e) {
    print('❌ Error cancelling appointment: $e');
    return false;
  }
}
