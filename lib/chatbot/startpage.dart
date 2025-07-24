import 'package:client/chatbot/chatbot.dart';
import 'package:flutter/material.dart';
import 'package:client/chatbot/chatbubble.dart';
import 'package:client/chatbot/chatbubbleuser.dart';

class Startpage extends StatefulWidget {
  const Startpage({super.key});

  @override
  State<Startpage> createState() => _Startpage();
}

class _Startpage extends State<Startpage> {
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
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 15),
            Center(
              child: Image.asset(
                'assets/therapist.png',
                width: 400,
                height: 400,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 50),
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Hey there, feeling low? Your virtual therapist is here to help",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 80),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Chatbot()),
                );
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 194, 178, 128),
              ),
              child: Text(
                "Start Conversation",
                style: TextStyle(
                  color: const Color.fromARGB(255, 252, 252, 252),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
