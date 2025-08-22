import 'dart:convert';
import 'package:http/http.dart' as http;

class Appointment {
  final String appId;
  final String userId;
  final String userName;
  final String date; // Display date (formatted)
  final String originalDate; // Original ISO date for parsing
  final String time;
  final String status;
  final String reminder;

  Appointment({
    required this.appId,
    required this.userId,
    required this.userName,
    required this.date,
    required this.originalDate, // Add this field
    required this.time,
    required this.status,
    required this.reminder,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    // Store original date for parsing
    String originalDate = json['date']?.toString() ?? '';
    
    // Format the date for display
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
      appId: json['app_id']?.toString() ?? json['doc_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      userName: json['user_name']?.toString() ?? '',
      date: formattedDate,
      originalDate: originalDate, // Store original ISO date
      time: formattedTime,
      status: json['status']?.toString() ?? '',
      reminder: json['reminder']?.toString() ?? 'off',
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
						originalDate: appointment.originalDate, // Add this line everywhere
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
						originalDate: appointment.originalDate, // Add this line
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
                // The doc_id should be available in the JSON response from the backend
                String doctorId = json['doc_id']?.toString() ?? '';
                String doctorName = 'Unknown Doctor';
                
                if (doctorId.isNotEmpty) {
                    doctorName = await fetchUserName(doctorId); // Use doc_id to fetch doctor name
                }
                
                // Create new appointment with doctor name
                appointments.add(Appointment(
                    appId: appointment.appId,
                    userId: appointment.userId,
                    userName: doctorName, // This will show the doctor's name for patient view
                    date: appointment.date,
                    originalDate: appointment.originalDate, // Add this line
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

	static Future<List<Appointment>> fetchPendingAppointmentsForDoctor(String? doctorId) async {
		if (doctorId == null || doctorId.isEmpty) {
			throw Exception('Doctor ID is required');
		}

		try {
			print('🌐 Making request to: $baseUrl/pending-appointments/doctor/$doctorId');
			final response = await http.get(
				Uri.parse('$baseUrl/pending-appointments/doctor/$doctorId'),
				headers: {'Content-Type': 'application/json'},
			);
			
			print('📡 Response status: ${response.statusCode}');
			print('📋 Response body: ${response.body}');
			
			if (response.statusCode == 200) {
				final List<dynamic> data = json.decode(response.body);
				print('✅ Parsed ${data.length} pending appointments from API for doctor: $doctorId');
				
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
						originalDate: appointment.originalDate, // Add this line
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
			throw Exception('Failed to load pending appointments for doctor: $e');
		}
	}

	static Future<bool> updateAppointmentStatus(String appointmentId, String status) async {
		try {
			print('🌐 Making request to update appointment status: $baseUrl/update-appointment-status/$appointmentId');
			final response = await http.put(
				Uri.parse('$baseUrl/update-appointment-status/$appointmentId'),
				headers: {'Content-Type': 'application/json'},
				body: json.encode({'status': status}),
			);
			
			print('📡 Update status response status: ${response.statusCode}');
			print('📋 Update status response body: ${response.body}');
			
			if (response.statusCode == 200) {
				final Map<String, dynamic> data = json.decode(response.body);
				return data['success'] == true;
			} else {
				print('❌ Failed to update appointment status: ${response.statusCode}');
				return false;
			}
		} catch (e) {
			print('❌ Error updating appointment status: $e');
			return false;
		}
	}

	static Future<List<int>> fetchMonthlyAppointmentStats(String doctorId) async {
    try {
        print('🌐 Making request to: $baseUrl/doctor/monthly-stats/$doctorId');
        final response = await http.get(
            Uri.parse('$baseUrl/doctor/monthly-stats/$doctorId'),
            headers: {'Content-Type': 'application/json'},
        );
        
        print('📡 Monthly stats response status: ${response.statusCode}');
        print('📋 Monthly stats response body: ${response.body}');
        
        if (response.statusCode == 200) {
            final List<dynamic> data = json.decode(response.body);
            return data.map((e) => (e as num).toInt()).toList(); // Fixed: Cast to num first, then toInt()
        } else {
            // Return default array of 12 zeros if error
            return List.generate(12, (index) => 0);
        }
    } catch (e) {
        print('❌ Error fetching monthly stats: $e');
        return List.generate(12, (index) => 0);
    }
}

	static Future<bool> incrementMonthlyAppointments(String doctorId, int month) async {
  try {
    print('🌐 incrementMonthlyAppointments called with doctorId: $doctorId, month: $month');
    print('🌐 Making request to: $baseUrl/doctor/increment-monthly/$doctorId');
    
    final response = await http.post(
      Uri.parse('$baseUrl/doctor/increment-monthly/$doctorId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'month': month}),
    );
    
    print('📡 Increment response status: ${response.statusCode}');
    print('📡 Increment response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('✅ Increment successful: ${responseData}');
      return true;
    } else {
      print('❌ Increment failed with status: ${response.statusCode}');
      return false;
    }
  } catch (e, stackTrace) {
    print('❌ Error incrementing monthly stats: $e');
    print('❌ Stack trace: $stackTrace');
    return false;
  }
}

	static Future<bool> decrementMonthlyAppointments(String doctorId, int month) async {
		try {
			print('🌐 decrementMonthlyAppointments called with doctorId: $doctorId, month: $month');
			print('🌐 Making request to: $baseUrl/doctor/decrement-monthly/$doctorId');
			
			final response = await http.post(
				Uri.parse('$baseUrl/doctor/decrement-monthly/$doctorId'),
				headers: {'Content-Type': 'application/json'},
				body: json.encode({'month': month}),
			);
			
			print('📡 Decrement response status: ${response.statusCode}');
			print('📡 Decrement response body: ${response.body}');
			
			if (response.statusCode == 200) {
				final responseData = json.decode(response.body);
				print('✅ Decrement successful: ${responseData}');
				return true;
			} else {
				print('❌ Decrement failed with status: ${response.statusCode}');
				return false;
			}
		} catch (e, stackTrace) {
			print('❌ Error decrementing monthly stats: $e');
			print('❌ Stack trace: $stackTrace');
			return false;
		}
	}
}
