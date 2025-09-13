import 'package:client/appointment/backend.dart';
import 'package:client/appointment/bookform.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'therapistcard.dart'; // Import the TherapistCard widget

class Therapist {
  final String docId;
  final String name;
  final String institution;
  final String imagepath;
  final String shortbio;
  final String education;
  final String description;
  final String special;
  final String exp;

  Therapist({
    required this.docId,
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
  final String userId;

  BookAppt({super.key, required this.userId});

  @override
  State<BookAppt> createState() => _BookAppt();
}

class _BookAppt extends State<BookAppt> {
  final searchController = TextEditingController();
  final focusNode = FocusNode();

  final Color purple = const Color.fromARGB(255, 211, 154, 213);

  List<Therapist> therapistinfo = [];
  List<Therapist> filteredTherapists = [];
  bool isLoading = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    print(widget.userId);
    fetchTherapists();
  }

  @override
  void dispose() {
    searchController.dispose();
    focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Fetch therapists data from the backend API
  Future<void> fetchTherapists() async {
    try {
      // Call GetTherapist to get the data
      final data = await GetTherapist();

      print("Therapist");
      print(data);
      // Process the therapist data from the backend
      List<Therapist> therapists = data.map((item) {
        return Therapist(
          docId: item['doc_id'] ?? '', // doc_id is already a string (UUID)
          name:
              item['name'] ??
              'Unknown', // Using bdn as name since name field doesn't exist
          institution: item['institute'] ?? 'Unknown Institution',
          imagepath: item['profileImage'] ?? 'assets/default_image.png',
          shortbio: item['shortbio'] ?? 'No bio available',
          education: item['education'] ?? 'No education details',
          description: item['description'] ?? 'No description available',
          special: item['special'] != null
              ? (item['special'] is List
                    ? (item['special'] as List).join(', ')
                    : item['special'].toString())
              : 'No specialties listed',
          exp: item['exp'] ?? 'No experience listed',
        );
      }).toList();

      setState(() {
        therapistinfo = therapists; // Set the list of therapists
        filteredTherapists = therapists; // Initialize filtered list
        isLoading = false; // Stop the loading spinner once data is fetched
      });
    } catch (e) {
      setState(() {
        isLoading = false; // Stop the loading spinner on error
      });
      print('Error: $e'); // Print the error message in the console
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
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
                      onChanged: (value) {
                        if (_debounce?.isActive ?? false) _debounce?.cancel();
                        _debounce = Timer(
                          const Duration(milliseconds: 500),
                          () {
                            setState(() {
                              filteredTherapists = therapistinfo.where((t) {
                                final searchLower = value.toLowerCase().trim();
                                final nameLower = t.name.toLowerCase();
                                final institutionLower = t.institution
                                    .toLowerCase();
                                final specialLower = t.special.toLowerCase();
                                final bioLower = t.shortbio.toLowerCase();

                                return searchLower.isEmpty ||
                                    nameLower.contains(searchLower) ||
                                    institutionLower.contains(searchLower) ||
                                    specialLower.contains(searchLower) ||
                                    bioLower.contains(searchLower);
                              }).toList();
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        ) // Show loading spinner when fetching
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            int crossCount = 2;
                            if (constraints.maxWidth >= 700 &&
                                constraints.maxWidth < 1000) {
                              crossCount = 3;
                            } else if (constraints.maxWidth >= 1000) {
                              crossCount = 4;
                            }

                            // Use the filtered list instead of filtering again
                            final filtered = filteredTherapists;

                            return GridView.builder(
                              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
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
                                  onTap: () =>
                                      _showTherapistDetails(context, t),
                                  child: TherapistCard(
                                    docId: t.docId,
                                    name: t.name,
                                    institution: t.institution,
                                    imagepath: t.imagepath,
                                    shortbio: t.shortbio,
                                    description: t.description,
                                    education: t.education,
                                    special: t.special,
                                    exp: t.exp,
                                    userId: widget.userId,
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookForm(
                    docId: t.docId,
                    name: t.name,
                    institution: t.institution,
                    imagepath: t.imagepath,
                    shortbio: t.shortbio,
                    education: t.education,
                    description: t.description,
                    special: t.special,
                    exp: t.exp,
                    userId: widget.userId,
                  ), // Pass userId if needed
                ),
              );
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
