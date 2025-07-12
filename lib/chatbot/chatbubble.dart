import 'package:flutter/material.dart';

void main() {
  runApp(const ChatbotBubble());
}

class ChatbotBubble extends StatefulWidget {
  const ChatbotBubble({super.key});

  @override
  State<ChatbotBubble> createState() => _ChatbotBubbleState();
}

class _ChatbotBubbleState extends State<ChatbotBubble> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 50,
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    );
  }
}
