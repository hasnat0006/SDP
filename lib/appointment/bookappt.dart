import 'package:flutter/material.dart';
import 'package:client/appointment/therapistcard.dart';

class Therapist {
  final String name;
  final String institution;
  final String imagepath;
  final String shortbio;

  Therapist({
    required this.name,
    required this.institution,
    required this.imagepath,
    required this.shortbio,
  });
}

class BookAppt extends StatefulWidget {
  const BookAppt({super.key});

  @override
  State<BookAppt> createState() => _BookAppt();
}

class _BookAppt extends State<BookAppt> {
  final List<Therapist> therapistinfo = [
    Therapist(
      name: 'Nabiha Parvez',
      institution: 'National Institute of Mental Health and Hospital',
      imagepath: 'assets/nabiha.jpeg',
      shortbio:
          'Dr Nabiha is a qualified and compassionate psychiatrist with over 10 years of experience helping individuals manage mental health concerns. She specializes in anxiety, depression, and stress management, and provides personalized care tailored to each patient\'s unique needs.',
    ),
    Therapist(
      name: 'Yusuf Reza',
      institution: 'National Institute of Mental Health and Hospital',
      imagepath: 'assets/hasnat.jpg',
      shortbio:
          'Dr Yusuf is a qualified and compassionate psychiatrist with over 10 years of experience helping individuals manage mental health concerns. He specializes in anxiety, depression, and stress management, and provides personalized care tailored to each patient\'s unique needs.',
    ),
    Therapist(
      name: 'Nazifa Zahin Ifrit',
      institution: 'National Institute of Mental Health and Hospital',
      imagepath: 'assets/ifrit.jpeg',
      shortbio:
          'Dr Ifrit is a qualified and compassionate psychiatrist with over 10 years of experience helping individuals manage mental health concerns. She specializes in anxiety, depression, and stress management, and provides personalized care tailored to each patient\'s unique needs.',
    ),
    Therapist(
      name: 'Tanvin Sarkar',
      institution: 'National Institute of Mental Health and Hospital',
      imagepath: 'assets/therapist.png',
      shortbio:
          'Dr Tanvin is a qualified and compassionate psychiatrist with over 10 years of experience helping individuals manage mental health concerns. He specializes in anxiety, depression, and stress management, and provides personalized care tailored to each patient\'s unique needs.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 211, 154, 213),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        title: Text(
          'Find your therapist',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        centerTitle: true,
        leading: Icon(Icons.arrow_back),
      ),
      body: Container(
        color: const Color.fromARGB(255, 247, 244, 242),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(0.8),
              color: Colors.white,
              child: TextField(
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.search),
                  hintText: 'Search for the best therapists',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 30),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.55,
                ),

                itemCount: therapistinfo.length,
                itemBuilder: (context, index) => TherapistCard(
                  name: therapistinfo[index].name,
                  institution: therapistinfo[index].institution,
                  imagepath: therapistinfo[index].imagepath,
                  shortbio: therapistinfo[index].shortbio,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
