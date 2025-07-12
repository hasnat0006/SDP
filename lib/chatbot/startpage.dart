import 'package:client/chatbot/chatbot.dart';
import 'package:flutter/material.dart';
import 'package:client/chatbot/chatbubble.dart';
import 'package:client/chatbot/chatbubbleuser.dart';

void main() {
  runApp(const Startpage());
}

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
        child: Center(
          child: Image.asset(
            'lib/chatbot/images',
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
