import 'package:client/chatbot/chatbubble.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const Chatbot());
}

class Chatbot extends StatefulWidget {
  const Chatbot({super.key});

  @override
  State<Chatbot> createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 211, 154, 213),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),

      body: Container(
        child: Column(
          children: [
            ChatbotBubble(),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(0.8),
              color: Colors.white,
              child: TextField(
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.send),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
