import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final searchController = TextEditingController();
  final focusNode = FocusNode();

  final Color purple = const Color.fromARGB(255, 211, 154, 213);

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
          'Depression & Anxiety Disorders\nStress Management\nBehavioural Therapy\nTrauma And PTSD',
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
  void dispose() {
    searchController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: purple,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            'Find your therapist',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFF7F4F2),
                Colors.purple[50]!.withOpacity(0.85),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Material(
                    elevation: 3,
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    child: TextField(
                      controller: searchController,
                      focusNode: focusNode,
                      style: GoogleFonts.poppins(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search for the best therapists',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      int crossCount = 2;
                      if (constraints.maxWidth >= 700 &&
                          constraints.maxWidth < 1000) {
                        crossCount = 3;
                      } else if (constraints.maxWidth >= 1000) {
                        crossCount = 4;
                      }

                      final filtered = therapistinfo.where((t) {
                        final q = searchController.text.trim().toLowerCase();
                        if (q.isEmpty) return true;
                        return t.name.toLowerCase().contains(q) ||
                            t.institution.toLowerCase().contains(q) ||
                            t.special.toLowerCase().contains(q) ||
                            t.shortbio.toLowerCase().contains(q);
                      }).toList();

                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.62,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final t = filtered[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _showTherapistDetails(context, t),
                            child: TherapistCard(
                              name: t.name,
                              institution: t.institution,
                              imagepath: t.imagepath,
                              shortbio: t.shortbio,
                              description: t.description,
                              education: t.education,
                              special: t.special,
                              exp: t.exp,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTherapistDetails(BuildContext context, Therapist t) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        title: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: AssetImage(t.imagepath),
              backgroundColor: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t.institution,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (t.shortbio.isNotEmpty) ...[
                _sectionTitle('About'),
                Text(
                  t.shortbio,
                  style: GoogleFonts.poppins(fontSize: 13.5, height: 1.4),
                ),
                const SizedBox(height: 10),
              ],
              if (t.special.isNotEmpty) ...[
                _sectionTitle('Specialties'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: t.special
                      .split('\n')
                      .where((s) => s.trim().isNotEmpty)
                      .map((s) => _chip(s.trim()))
                      .toList(),
                ),
                const SizedBox(height: 10),
              ],
              if (t.education.isNotEmpty) ...[
                _sectionTitle('Education'),
                Text(
                  t.education,
                  style: GoogleFonts.poppins(fontSize: 13.5, height: 1.4),
                ),
                const SizedBox(height: 10),
              ],
              if (t.exp.isNotEmpty) ...[
                _sectionTitle('Experience'),
                Text(
                  t.exp,
                  style: GoogleFonts.poppins(fontSize: 13.5, height: 1.4),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: purple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              // Navigate to your booking flow from here if desired.
            },
            child: Text(
              'Book',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Colors.purple[900],
        ),
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 12, color: Colors.purple[900]),
      ),
    );
  }
}
