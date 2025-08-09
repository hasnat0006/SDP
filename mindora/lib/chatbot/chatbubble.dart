import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatbotBubble extends StatelessWidget {
  const ChatbotBubble({super.key});

  final String text = 'Hey there, how can I help you?';

  @override
  Widget build(BuildContext context) {
    final purple = const Color.fromARGB(255, 211, 154, 213);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Therapist avatar
          CircleAvatar(
            radius: 22,
            backgroundImage: const AssetImage('assets/therapist.png'),
            backgroundColor: Colors.white,
          ),
          const SizedBox(width: 10),
          // Bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[900],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
