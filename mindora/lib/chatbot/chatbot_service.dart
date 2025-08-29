import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatbotService {
  late GenerativeModel model;
  late ChatSession chat;

  ChatbotService() {
    final apiKey = dotenv.env['GEMINI_API'] ?? '';
    model = GenerativeModel(
      model:
          'gemini-1.5-flash', // Changed from 'gemini-pro' to 'gemini-1.0-pro'
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topP: 0.8,
        topK: 40,
        maxOutputTokens: 2048,
      ),
    );

    // Initialize chat with therapist context
    chat = model.startChat(
      history: [
        Content.text(
          'You are a kind, empathetic, and professional therapist. Your responses should be:'
          '\n- Compassionate and understanding'
          '\n- Non-judgmental and supportive'
          '\n- Professional but warm'
          '\n- Focused on emotional support'
          '\n- Brief and clear (keep responses under 100 words)'
          '\nAvoid giving medical advice or diagnosing conditions.',
        ),
      ],
    );
  }

  Future<String> sendMessage(String message) async {
    try {
      final response = await chat.sendMessage(Content.text(message));
      return response.text ??
          'I apologize, but I am unable to respond at the moment.';
    } catch (e) {
      print('Error sending message: $e');
      return 'I apologize, but I encountered an error. Please try again.';
    }
  }
}
