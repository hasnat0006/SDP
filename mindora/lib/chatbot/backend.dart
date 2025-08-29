import '../backend/main_query.dart';

Future<void> saveChatMessage({
  required String userId,
  required String message,
  required bool isUser,
}) async {
  try {
    // Get current date
    final now = DateTime.now();
    final date = now.toIso8601String().split('T')[0]; // Gets YYYY-MM-DD format

    // Create conversation JSON structure
    final conversation = {
      'messages': [
        {
          'content': message,
          'role': isUser ? 'user' : 'assistant',
          'timestamp': now.toIso8601String(),
        },
      ],
      'metadata': {
        'userId': userId,
        'date': date, // Add date in YYYY-MM-DD format
        'sessionTime': now.toIso8601String(),
      },
    };

    await postToBackend('chat/save', {
      'userId': userId,
      'conversation': conversation,
      'date': date, // Add date to the request
    });
    print('✅ Chat message saved with date: $date');
  } catch (e) {
    print('❌ Error saving chat message: $e');
    rethrow;
  }
}

Future<List<Map<String, dynamic>>> getChatHistory(String userId) async {
  try {
    final response = await getFromBackend('chat/history/$userId');
    print('✅ Chat history fetched');

    // Parse the JSONB response
    return List<Map<String, dynamic>>.from(response).map((item) {
      final conversation = item['conversation'];
      final messages = List<Map<String, dynamic>>.from(
        conversation['messages'],
      );
      return {
        'conversation': messages,
        'metadata': conversation['metadata'],
        'date': item['date'], // Include date in the returned data
      };
    }).toList();
  } catch (e) {
    print('❌ Error fetching chat history: $e');
    return [];
  }
}

// Add a method to get chats by date
// Future<List<Map<String, dynamic>>> getChatsByDate(
//   String userId,
//   String date,
// ) async {
//   try {
//     final response = await getFromBackend('chat/history/$userId/$date');
//     print('✅ Chat history fetched for date: $date');

//     return List<Map<String, dynamic>>.from(response);
//   } catch (e) {
//     print('❌ Error fetching chat history for date: $e');
//     return [];
//   }
// }
