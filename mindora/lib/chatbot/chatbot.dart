import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chatbubble.dart';
import 'chatbubbleuser.dart';
import 'chatbot_service.dart';
import 'backend.dart';

class Chatbot extends StatefulWidget {
  final String userId;
  const Chatbot({super.key, required this.userId});

  @override
  State<Chatbot> createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  late final ChatbotService _chatbot;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize chatbot with user ID
    _chatbot = ChatbotService(userId: widget.userId);

    // Add initial greeting
    _messages.add(
      Message(
        text:
            "Hello! I'm here to listen and support you. How are you feeling today?",
        isUser: false,
      ),
    );

    // Load chat history
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    try {
      final history = await getChatHistory(widget.userId);
      if (history.isEmpty) return;

      setState(() {
        // Clear initial greeting if we have history
        _messages.clear();

        for (var item in history) {
          if (item['conversation'] != null) {
            final messages = List<Map<String, dynamic>>.from(
              item['conversation'],
            );
            for (var msg in messages) {
              _messages.add(
                Message(
                  text: msg['content']?.toString() ?? '',
                  isUser: msg['role'] == 'user',
                  timestamp: msg['timestamp'] != null
                      ? DateTime.parse(msg['timestamp'])
                      : DateTime.now(),
                ),
              );
            }
          }
        }
      });
      _scrollToBottom();
    } catch (e) {
      print('Error loading chat history: $e');
      print('Error details: ${e.toString()}');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = Message(text: text, isUser: true);

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final response = await _chatbot.sendMessage(text);
      setState(() {
        _messages.add(Message(text: response, isUser: false));
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(
          Message(
            text:
                "I'm sorry, I'm having trouble responding right now. Please try again.",
            isUser: false,
          ),
        );
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 211, 154, 213),
        title: Text(
          'Virtual Therapist',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return message.isUser
                    ? UserMessageBubble(text: message.text)
                    : BotMessageBubble(text: message.text);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (text) => _sendMessage(text),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: const Color.fromARGB(255, 211, 154, 213),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Update Message class
class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Message({required this.text, required this.isUser, DateTime? timestamp})
    : this.timestamp = timestamp ?? DateTime.now();

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['content']?.toString() ?? '',
      isUser: json['role'] == 'user',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'content': text,
    'role': isUser ? 'user' : 'assistant',
    'timestamp': timestamp.toIso8601String(),
  };
}
