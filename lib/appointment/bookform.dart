import 'package:flutter/material.dart';
import 'package:client/appointment/therapistcard.dart';

class BookForm extends StatefulWidget {
  const BookForm({super.key});

  @override
  State<BookForm> createState() => _BookForm();
}

class _BookForm extends State<BookForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 211, 154, 213),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),

        centerTitle: true,
        leading: Icon(Icons.arrow_back),
      ),
    );
  }
}
