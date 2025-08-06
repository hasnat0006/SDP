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
