import 'package:intl/intl.dart';
import '../backend/main_query.dart'; 

Future<void> saveJournalEntry(String title, String content, String userId) async {
  final String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final String currentTime = DateFormat('HH:mm:ss').format(DateTime.now());

  final Map<String, dynamic> data = {
    'user_id': userId, // Make sure this uses the passed userId, not hardcoded
    'title': title,
    'information': content,
    'date': currentDate,
    'time': currentTime,
  };

  try {
    await postToBackend('journal', data);
    print('✅ Journal saved for user: $userId');
  } catch (e) {
    print('❌ Error saving journal: $e');
    rethrow;
  }
}

Future<List<Map<String, dynamic>>> fetchJournalEntries(String userId) async {
  final endpoint = 'journal?user_id=$userId'; // Make sure this uses dynamic userId
  
  print('📡 Fetching journals for user: $userId'); // Debug print

  try {
    final response = await getFromBackend(endpoint);
    final List<dynamic> journalList = response['journals'];
    print('📚 Fetched ${journalList.length} journals for user: $userId');
    return List<Map<String, dynamic>>.from(journalList);
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
