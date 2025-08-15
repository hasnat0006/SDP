
import 'dart:convert';
import 'package:http/http.dart' as http;

class Appointment {
	final String appId; // Changed from int to String to handle UUIDs
	final String userId; // Changed from int to String to handle UUIDs
	final String userName; // Add user name field
	final String date;
	final String time;
	final String status;
	final String reminder; // Add reminder field

	Appointment({
		required this.appId,
		required this.userId,
		required this.userName,
		required this.date,
		required this.time,
		required this.status,
		required this.reminder,
	});

	factory Appointment.fromJson(Map<String, dynamic> json) {
		// Format the date properly
		String formattedDate = '';
		if (json['date'] != null) {
			try {
				DateTime dateTime = DateTime.parse(json['date']);
				formattedDate = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
			} catch (e) {
				formattedDate = json['date']?.toString() ?? '';
			}
		}

		// Format the time properly
		String formattedTime = '';
		if (json['time'] != null) {
			try {
				// If it's in HH:mm:ss format, just take HH:mm
				String timeStr = json['time'].toString();
				if (timeStr.contains(':')) {
					List<String> timeParts = timeStr.split(':');
					formattedTime = '${timeParts[0]}:${timeParts[1]}';
				} else {
					formattedTime = timeStr;
				}
			} catch (e) {
				formattedTime = json['time']?.toString() ?? '';
			}
		}

		return Appointment(
			appId: json['doc_id']?.toString() ?? json['app_id']?.toString() ?? '', // Handle both doc_id and app_id as strings
			userId: json['user_id']?.toString() ?? '',
			userName: json['user_name']?.toString() ?? '', // Will be populated later
			date: formattedDate,
			time: formattedTime,
			status: json['status']?.toString() ?? '',
			reminder: json['reminder']?.toString() ?? 'off', // Default to 'off' if not provided
		);
	}
}

class PatientDetails {
	final String name;
	final String gender;
	final String dob;
	final String profession;
	final String age; // Changed from int to String to handle empty values

	PatientDetails({
		required this.name,
		required this.gender,
		required this.dob,
		required this.profession,
		required this.age,
	});

	factory PatientDetails.fromJson(Map<String, dynamic> json) {
		// Calculate age from dob
		String calculatedAge = '';
		if (json['dob'] != null && json['dob'].toString().isNotEmpty) {
			try {
				DateTime dobDate = DateTime.parse(json['dob']);
				DateTime now = DateTime.now();
				int ageInYears = now.year - dobDate.year;
				if (now.month < dobDate.month || (now.month == dobDate.month && now.day < dobDate.day)) {
					ageInYears--;
				}
				calculatedAge = '$ageInYears years';
			} catch (e) {
				calculatedAge = '';
			}
		}

		return PatientDetails(
			name: json['name']?.toString() ?? '',
			gender: json['gender']?.toString() ?? '',
			dob: json['dob']?.toString() ?? '',
			profession: json['profession']?.toString() ?? '',
			age: calculatedAge,
		);
	}
}

class AppointmentService {
	static const String baseUrl = 'http://127.0.0.1:5000'; // Backend server URL

	static Future<String> fetchUserName(String userId) async {
		try {
			final response = await http.get(
				Uri.parse('$baseUrl/user/$userId'),
				headers: {'Content-Type': 'application/json'},
			);
			
			if (response.statusCode == 200) {
				final Map<String, dynamic> data = json.decode(response.body);
				return data['name']?.toString() ?? 'Unknown User';
			} else {
				return 'Unknown User';
			}
		} catch (e) {
			print('❌ Error fetching user name: $e');
			return 'Unknown User';
		}
	}

	static Future<PatientDetails?> fetchPatientDetails(String userId) async {
		try {
			print('🌐 Fetching patient details for user: $userId');
			final response = await http.get(
				Uri.parse('$baseUrl/patient/$userId'),
				headers: {'Content-Type': 'application/json'},
			);
			
			print('📡 Patient response status: ${response.statusCode}');
			print('📋 Patient response body: ${response.body}');
			
			if (response.statusCode == 200) {
				final Map<String, dynamic> data = json.decode(response.body);
				return PatientDetails.fromJson(data);
			} else {
				print('❌ Patient not found or error: ${response.statusCode}');
				return null;
			}
		} catch (e) {
			print('❌ Error fetching patient details: $e');
			return null;
		}
	}

	static Future<List<Appointment>> fetchConfirmedAppointments() async {
		try {
			print('🌐 Making request to: $baseUrl/confirmed-appointments');
			final response = await http.get(
				Uri.parse('$baseUrl/confirmed-appointments'),
				headers: {'Content-Type': 'application/json'},
			);
			
			print('📡 Response status: ${response.statusCode}');
			print('📋 Response body: ${response.body}');
			
			if (response.statusCode == 200) {
				final List<dynamic> data = json.decode(response.body);
				print('✅ Parsed ${data.length} appointments from API');
				
				// Create appointments and fetch user names
				List<Appointment> appointments = [];
				for (var json in data) {
					var appointment = Appointment.fromJson(json);
					// Fetch user name for this appointment
					String userName = await fetchUserName(appointment.userId);
					
					// Create new appointment with user name
					appointments.add(Appointment(
						appId: appointment.appId,
						userId: appointment.userId,
						userName: userName,
						date: appointment.date,
						time: appointment.time,
						status: appointment.status,
						reminder: appointment.reminder,
					));
				}
				
				return appointments;
			} else {
				throw Exception('Server returned status ${response.statusCode}: ${response.body}');
			}
		} catch (e) {
			print('❌ AppointmentService error: $e');
			throw Exception('Failed to load confirmed appointments: $e');
		}
	}

	static Future<List<Appointment>> fetchConfirmedAppointmentsForDoctor(String? doctorId) async {
		if (doctorId == null || doctorId.isEmpty) {
			// Fallback to all appointments if no doctor ID
			return fetchConfirmedAppointments();
		}

		try {
			print('🌐 Making request to: $baseUrl/confirmed-appointments/doctor/$doctorId');
			final response = await http.get(
				Uri.parse('$baseUrl/confirmed-appointments/doctor/$doctorId'),
				headers: {'Content-Type': 'application/json'},
			);
			
			print('📡 Response status: ${response.statusCode}');
			print('📋 Response body: ${response.body}');
			
			if (response.statusCode == 200) {
				final List<dynamic> data = json.decode(response.body);
				print('✅ Parsed ${data.length} appointments from API for doctor: $doctorId');
				
				// Create appointments and fetch user names
				List<Appointment> appointments = [];
				for (var json in data) {
					var appointment = Appointment.fromJson(json);
					// Fetch user name for this appointment
					String userName = await fetchUserName(appointment.userId);
					
					// Create new appointment with user name
					appointments.add(Appointment(
						appId: appointment.appId,
						userId: appointment.userId,
						userName: userName,
						date: appointment.date,
						time: appointment.time,
						status: appointment.status,
						reminder: appointment.reminder,
					));
				}
				
				return appointments;
			} else {
				throw Exception('Server returned status ${response.statusCode}: ${response.body}');
			}
		} catch (e) {
			print('❌ AppointmentService error: $e');
			throw Exception('Failed to load confirmed appointments for doctor: $e');
		}
	}

	static Future<List<Appointment>> fetchMyAppointments(String? userId) async {
		if (userId == null || userId.isEmpty) {
			throw Exception('User ID is required');
		}

		try {
			print('🌐 Making request to: $baseUrl/my-appointments/$userId');
			final response = await http.get(
				Uri.parse('$baseUrl/my-appointments/$userId'),
				headers: {'Content-Type': 'application/json'},
			);
			
			print('📡 Response status: ${response.statusCode}');
			print('📋 Response body: ${response.body}');
			
			if (response.statusCode == 200) {
				final List<dynamic> data = json.decode(response.body);
				print('✅ Parsed ${data.length} my appointments from API for user: $userId');
				
				// Create appointments and fetch doctor names
				List<Appointment> appointments = [];
				for (var json in data) {
					var appointment = Appointment.fromJson(json);
					// For patient view, we want to show doctor name instead of user name
					String doctorName = await fetchUserName(appointment.appId); // appId contains doc_id
					
					// Create new appointment with doctor name
					appointments.add(Appointment(
						appId: appointment.appId,
						userId: appointment.userId,
						userName: doctorName, // This will show the doctor's name for patient view
						date: appointment.date,
						time: appointment.time,
						status: appointment.status,
						reminder: appointment.reminder,
					));
				}
				
				return appointments;
			} else {
				throw Exception('Server returned status ${response.statusCode}: ${response.body}');
			}
		} catch (e) {
			print('❌ AppointmentService error: $e');
			throw Exception('Failed to load my appointments: $e');
		}
	}

	static Future<bool> cancelAppointment(String appointmentId) async {
		try {
			print('🌐 Making request to cancel appointment: $baseUrl/cancel-appointment/$appointmentId');
			final response = await http.put(
				Uri.parse('$baseUrl/cancel-appointment/$appointmentId'),
				headers: {'Content-Type': 'application/json'},
			);
			
			print('📡 Cancel response status: ${response.statusCode}');
			print('📋 Cancel response body: ${response.body}');
			
			if (response.statusCode == 200) {
				final Map<String, dynamic> data = json.decode(response.body);
				return data['success'] == true;
			} else {
				print('❌ Failed to cancel appointment: ${response.statusCode}');
				return false;
			}
		} catch (e) {
			print('❌ Error cancelling appointment: $e');
			return false;
		}
	}

	static Future<bool> updateReminder(String appointmentId, String reminderStatus) async {
		try {
			print('🌐 Making request to update reminder: $baseUrl/update-reminder/$appointmentId');
			final response = await http.put(
				Uri.parse('$baseUrl/update-reminder/$appointmentId'),
				headers: {'Content-Type': 'application/json'},
				body: json.encode({'reminder': reminderStatus}),
			);
			
			print('📡 Update reminder response status: ${response.statusCode}');
			print('📋 Update reminder response body: ${response.body}');
			
			if (response.statusCode == 200) {
				final Map<String, dynamic> data = json.decode(response.body);
				return data['success'] == true;
			} else {
				print('❌ Failed to update reminder: ${response.statusCode}');
				return false;
			}
		} catch (e) {
			print('❌ Error updating reminder: $e');
			return false;
		}
	}
}
