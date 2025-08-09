import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';

String get apiUrl => dotenv.env['EMULATOR_URL'] ?? 'http://127.0.0.1:5000';

Future<Map<String, dynamic>> getFromBackend(String endpoint) async {
  try {
    final url = '$apiUrl/$endpoint';
    debugPrint('🌐 API: $url');

    final response = await http.get(Uri.parse(url));
 
    debugPrint('📡 Status: ${response.statusCode}');
    debugPrint('📄 Response: ${response.body}');
    // Pretty print JSON response in terminal
    try {
      final prettyJson = JsonEncoder.withIndent(
        '  ',
      ).convert(jsonDecode(response.body));
      debugPrint('📋 JSON response:\n$prettyJson');
    } catch (e) {
      debugPrint('⚠️ Could not format JSON: $e');
    }
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint('✅ Successfully parsed ${data.length} items from $endpoint');
      debugPrint('📊 Parsed data: $data');
      return data;
    } else {
      debugPrint('❌ Failed to load $endpoint: ${response.statusCode}');
      debugPrint('❌ Error body: ${response.body}');
      throw Exception('Failed to load $endpoint: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('🚨 Network error occurred: $e');
    throw Exception('Network error: $e');
  }
}


Future<List<dynamic>> postToBackend(
  String endpoint,
  Map<String, dynamic> data,
) async {
  try {
    final url = '$apiUrl/$endpoint';
    debugPrint('🌐 API: $url');

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    debugPrint('📡 Status: ${response.statusCode}');
    debugPrint('📄 Response: ${response.body}');
    // Pretty print JSON response in terminal
    try {
      final prettyJson = JsonEncoder.withIndent(
        '  ',
      ).convert(jsonDecode(response.body));
      debugPrint('📋 JSON response:\n$prettyJson');
    } catch (e) {
      debugPrint('⚠️ Could not format JSON: $e');
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      debugPrint('✅ Successfully processed $endpoint');
      debugPrint('📊 Response data: $data');
      return [data]; // Wrap in list for consistency
    } else {
      final errorData = jsonDecode(response.body);
      final errorMessage = errorData['error'] ?? 'Unknown error occurred';
      debugPrint('❌ Failed to process $endpoint: ${response.statusCode}');
      debugPrint('❌ Error: $errorMessage');
      throw Exception(errorMessage);
    }
  } catch (e) {
    debugPrint('🚨 Network error occurred: $e');
    throw Exception('Network error: $e');
  }
}
