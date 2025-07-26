import 'package:flutter/material.dart';
import 'package:client/appointment/therapistcard.dart';

class Therapist {
  final String name;
  final String institution;
  final String imagepath;
  final String shortbio;
  final String education;
  final String description;
  final String special;
  final String exp;

  Therapist({
    required this.name,
    required this.institution,
    required this.imagepath,
    required this.shortbio,
    required this.education,
    required this.description,
    required this.special,
    required this.exp,
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
      education:
          'MBBS, Sir Salimullah Medical College, 2005\n'
          'MD in Psychiatry, 2015\n'
          'FCPS Part 1 in Psychiatry, CPSB, 2018',
      description:
          '''Dr. Nabiha Parvez is a caring and dedicated psychiatrist who believes in providing holistic care to individuals struggling with mental health issues. With a patient-centered approach, Dr. Nabiha Parvez works to create a safe space for individuals to explore their thoughts, emotions, and behaviors.

Dr. Nabiha Parvez aims to empower individuals to take control of their mental health by offering support, understanding, and evidence-based treatment options. She values building trust with patients and is committed to making each consultation a personalized and productive experience.''',
      special:
          'Depression & Anxiety Disorders\nStress Management\nBehavioural Therapy\n Trauma And PTSD',
      exp:
          '10 Years of Experience\n'
          'Former Consulting Psychiatrist at Dhaka Medical College, 8 years\n'
          'Former Psychiatrist at Apollo Hospital, 2 years',
    ),
    Therapist(
      name: 'Yusuf Reza',
      institution: 'National Institute of Mental Health and Hospital',
      imagepath: 'assets/hasnat.jpg',
      shortbio:
          'Dr Yusuf is a qualified and compassionate psychiatrist with over 10 years of experience helping individuals manage mental health concerns. He specializes in anxiety, depression, and stress management, and provides personalized care tailored to each patient\'s unique needs.',
      education: '',
      description: '',
      special: '',
      exp: '10 years of experience',
    ),
    Therapist(
      name: 'Nazifa Zahin Ifrit',
      institution: 'National Institute of Mental Health and Hospital',
      imagepath: 'assets/ifrit.jpeg',
      shortbio:
          'Dr Ifrit is a qualified and compassionate psychiatrist with over 10 years of experience helping individuals manage mental health concerns. She specializes in anxiety, depression, and stress management, and provides personalized care tailored to each patient\'s unique needs.',
      education: '',
      description: '',
      special: '',
      exp: '10 years of experience',
    ),
    Therapist(
      name: 'Tanvin Sarkar',
      institution: 'National Institute of Mental Health and Hospital',
      imagepath: 'assets/therapist.png',
      shortbio:
          'Dr Tanvin is a qualified and compassionate psychiatrist with over 10 years of experience helping individuals manage mental health concerns. He specializes in anxiety, depression, and stress management, and provides personalized care tailored to each patient\'s unique needs.',
      education: '',
      description: '',
      special: '',
      exp: '10 years of experience',
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
                  description: therapistinfo[index].description,
                  education: therapistinfo[index].education,
                  special: therapistinfo[index].special,
                  exp: therapistinfo[index].exp, // <-- Add this line
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
