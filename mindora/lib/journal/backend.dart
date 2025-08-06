import 'package:intl/intl.dart';
import '../backend/main_query.dart'; 

Future<void> saveJournalEntry(String title, String content) async {
  const String userId = 'b87a924a-dbde-4a27-b3d0-ef44042fa607'; //I HAVE HARD CODED THIS, REMIND ME TO FIX LATER
  final String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final String currentTime = DateFormat('HH:mm:ss').format(DateTime.now());

  final Map<String, dynamic> data = {
  'user_id': userId,
  'title': title,
  'information': content,
  'date': currentDate,
  'time': currentTime,
};


  try {
    await postToBackend('journal', data);
  } catch (e) {
    print('Error saving journal: $e');
    rethrow;
  }
}

Future<List<Map<String, dynamic>>> fetchJournalEntries() async {
  const userId = 'b87a924a-dbde-4a27-b3d0-ef44042fa607';
  final endpoint = 'journal?user_id=$userId';

  try {
    final response = await getFromBackend(endpoint); // Map<String, dynamic>
    final List<dynamic> journalList = response['journals'];
    return List<Map<String, dynamic>>.from(journalList);
  } catch (e) {
    print('❌ Error in fetchJournalEntries: $e');
    rethrow;
  }
}
