
import 'dart:convert';
import 'package:http/http.dart' as http;

class Appointment {
	final String appId; // Changed from int to String to handle UUIDs
	final String userId; // Changed from int to String to handle UUIDs
	final String date;
	final String time;
	final String status;

	Appointment({
		required this.appId,
		required this.userId,
		required this.date,
		required this.time,
		required this.status,
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
			date: formattedDate,
			time: formattedTime,
			status: json['status']?.toString() ?? '',
		);
	}
}

class AppointmentService {
	static const String baseUrl = 'http://127.0.0.1:5000'; // Backend server URL

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
				return data.map((json) => Appointment.fromJson(json)).toList();
			} else {
				throw Exception('Server returned status ${response.statusCode}: ${response.body}');
			}
		} catch (e) {
			print('❌ AppointmentService error: $e');
			throw Exception('Failed to load confirmed appointments: $e');
		}
	}
}
