import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'backend.dart';

class ChatbotService {
  late GenerativeModel model;
  late ChatSession chat;
  final String userId;
  List<Map<String, dynamic>> messageHistory =
      []; // Add this line to store messages

  ChatbotService({required this.userId}) {
    final apiKey = dotenv.env['GEMINI_API'] ?? '';
    print('Using API key: $apiKey');

    model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topP: 0.8,
        topK: 40,
        maxOutputTokens: 2048,
      ),
    );

    chat = model.startChat(
      history: [
        Content.text(
          'You are a kind, empathetic, and professional therapist...',
        ),
      ],
    );

    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    try {
      final history = await getChatHistory(userId);
      List<Content> historyContent = []; // Create a temporary list

      for (final item in history) {
        final messages = List<Map<String, dynamic>>.from(item['conversation']);
        for (final msg in messages) {
          historyContent.add(Content.text(msg['content']));
        }
      }

      // Update chat with the new history
      chat = model.startChat(history: historyContent);

      print('✅ Chat history loaded successfully');
    } catch (e) {
      print('❌ Error loading chat history: $e');
    }
  }

  // Add a method to get message history
  List<Map<String, dynamic>> getMessageHistory() {
    return messageHistory;
  }

  // Add a method to add new message
  void addMessage(String content, bool isUser) {
    final message = {
      'content': content,
      'role': isUser ? 'user' : 'assistant',
      'timestamp': DateTime.now().toIso8601String(),
    };
    messageHistory.add(message);
  }

  Future<String> sendMessage(String message) async {
    try {
      print('📤 Sending message: $message');

      // Save user message
      await saveChatMessage(userId: userId, message: message, isUser: true);

      // Get bot response
      final response = await chat.sendMessage(Content.text(message));
      final botResponse =
          response.text ??
          'I apologize, but I am unable to respond at the moment.';

      print('📥 Received response: $botResponse');

      // Save bot response
      await saveChatMessage(
        userId: userId,
        message: botResponse,
        isUser: false,
      );

      return botResponse;
    } catch (e) {
      print('❌ Error sending message: $e');
      return 'I apologize, but I encountered an error. Please try again.';
    }
  }
}
