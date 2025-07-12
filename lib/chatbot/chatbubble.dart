import 'package:flutter/material.dart';

void main() {
  runApp(const ChatbotBubble());
}

class ChatbotBubble extends StatefulWidget {
  const ChatbotBubble({super.key});

  final String text = 'Hey there, How can I help you?';

  @override
  State<ChatbotBubble> createState() => _ChatbotBubbleState();
}

class _ChatbotBubbleState extends State<ChatbotBubble> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundImage: AssetImage(
            'lib/assets/ChatGPT Image Jul 8, 2025, 09_27_55 PM.png',
          ),
          backgroundColor: Colors.white,
        ),
        Container(
          height: 100,
          width: 250,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Hey there, How can I help you?',
              style: TextStyle(
                color: const Color.fromARGB(255, 5, 5, 5),
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
