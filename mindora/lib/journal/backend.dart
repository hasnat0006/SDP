import 'package:intl/intl.dart';
import '../backend/main_query.dart'; 
import 'mood_detector.dart';

Future<void> saveJournalEntry(String title, String content, String userId, String mood) async {
  final String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final String currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
  
  // Get mood color as hex string (remove alpha channel)
  final moodColor = MoodDetector.getMoodColor(mood);
  final colorHex = '#${moodColor.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

  final Map<String, dynamic> data = {
    'user_id': userId,
    'title': title,
    'information': content,
    'date': currentDate,
    'time': currentTime,
    'mood': mood,
    'mood_color': colorHex,
  };

  print('📤 SENDING DATA: $data');
  print('📤 MOOD VALUE: ${data['mood']} (type: ${data['mood'].runtimeType})');
  print('📤 MOOD_COLOR VALUE: ${data['mood_color']} (type: ${data['mood_color'].runtimeType})');
  print('📤 USER_ID: ${data['user_id']} (type: ${data['user_id'].runtimeType})');

  try {
    await postToBackend('journal', data);
    print('✅ Journal saved with mood: $mood');
  } catch (e) {
    print('❌ Error saving journal: $e');
    rethrow;
  }
}

Future<List<Map<String, dynamic>>> fetchJournalEntries(String userId) async {
  final endpoint = 'journal?user_id=$userId';

  try {
    final response = await getFromBackend(endpoint);
    print('📥 Fetched response: $response'); // Debug
    
    final List<dynamic> journalList = response['journals'];
    final List<Map<String, dynamic>> typedList = List<Map<String, dynamic>>.from(journalList);
    
    // Debug: Print each entry to see mood data
    for (var entry in typedList) {
      print('📋 Entry mood: ${entry['mood']}, mood_color: ${entry['mood_color']}');
    }
    
    return typedList;
  } catch (e) {
    print('❌ Error in fetchJournalEntries: $e');
    rethrow;
  }
}

Future<bool> updateJournalEntry({
  required String id,
  required String title,
  required String description,
}) async {
  const endpoint = 'journal/update';
 
  final body = {
    'id': id,
    'title': title,
    'description': description,
  };
  print('backend dart: $id');
  try {
    final response = await postToBackend(endpoint, body);
    return response.isNotEmpty;
  } catch (e) {
    print('Error updating journal: $e');
    return false;
  }
}

Future<bool> deleteJournalEntry(String id) async {
  const endpoint = 'journal/delete';

  final body = {
    'id': id,
  };

  try {
    final response = await postToBackend(endpoint, body);
    return response.isNotEmpty;
  } catch (e) {
    print('Error deleting journal: $e');
    return false;
  }
}
