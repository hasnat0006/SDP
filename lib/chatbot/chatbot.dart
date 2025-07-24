import 'package:client/chatbot/chatbot.dart';
import 'package:flutter/material.dart';
import 'package:client/chatbot/chatbubble.dart';
import 'package:client/chatbot/chatbubbleuser.dart';


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
        color: const Color.fromARGB(
          255,
          247,
          244,
          242,
        ), // Optional: background color
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16), // Space below AppBar
            ChatbotBubble(),
            SizedBox(height: 16),
            ChatbotBubbleuser(),
            Spacer(), // Pushes the TextField to the bottom
            Container(
              padding: EdgeInsets.all(1),
              color: Colors.white,
              child: TextField(
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.send),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      30,
                    ), // Makes the field round
                    borderSide: BorderSide(),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
