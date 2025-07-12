import 'package:flutter/material.dart';

void main() {
  runApp(const ChatbotBubbleuser());
}

class ChatbotBubbleuser extends StatefulWidget {
  const ChatbotBubbleuser({super.key});

  final String text = 'Hey there, How can I help you?';

  @override
  State<ChatbotBubbleuser> createState() => _ChatbotBubbleuserState();
}

class _ChatbotBubbleuserState extends State<ChatbotBubbleuser> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: 100,
          width: 250,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 211, 154, 213),
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'I had a really bad day at work.',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 243, 243, 243),
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.start,
                ),
                // Add Spacer() or SizedBox if you want extra space below the text
              ],
            ),
          ),
        ),
        SizedBox(width: 8), // Space between bubble and icon
        Icon(Icons.done_all, color: Colors.purple, size: 20),
      ],
    );
  }
}
