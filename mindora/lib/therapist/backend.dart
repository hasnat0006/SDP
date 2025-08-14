
import 'dart:convert';
import 'package:http/http.dart' as http;

class Appointment {
	final int appId;
	final int userId;
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
		return Appointment(
			appId: json['app_id'],
			userId: json['user_id'],
			date: json['date'],
			time: json['time'],
			status: json['status'],
		);
	}
}

class AppointmentService {
	static const String baseUrl = 'http://127.0.0.1:5000'; // Backend server URL

	static Future<List<Appointment>> fetchConfirmedAppointments() async {
		final response = await http.get(Uri.parse('$baseUrl/confirmed-appointments'));
		if (response.statusCode == 200) {
			final List<dynamic> data = json.decode(response.body);
			return data.map((json) => Appointment.fromJson(json)).toList();
		} else {
			throw Exception('Failed to load confirmed appointments');
		}
	}
}
