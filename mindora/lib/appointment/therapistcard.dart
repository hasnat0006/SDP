import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bookform.dart';
import 'viewdetails.dart';

class TherapistCard extends StatelessWidget {
  final String name;
  final String institution;
  final String imagepath;
  final String shortbio;
  final String description;
  final String education;
  final String special;
  final String exp;

  const TherapistCard({
    super.key,
    required this.name,
    required this.institution,
    required this.imagepath,
    required this.shortbio,
    required this.description,
    required this.education,
    required this.special,
    required this.exp,
  });

  @override
  Widget build(BuildContext context) {
    final purple = const Color.fromARGB(255, 211, 154, 213);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Circular avatar
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage(imagepath),
              ),
            ),

            const SizedBox(height: 10),

            // Therapist Name
            Text(
              name,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 6),

            // Institution
            Text(
              institution,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const Spacer(),

            // Book & Details Buttons — identical look
            Row(
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookForm(
                              name: name,
                              institution: institution,
                              imagepath: imagepath,
                              shortbio: shortbio,
                              description: description,
                              education: education,
                              special: special,
                              exp: exp,
                            ),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.event_available,
                        size: 18,
                        color: purple,
                      ),
                      label: Text(
                        'Book',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: purple,
                          fontSize: 14,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: purple, width: 1.2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Viewdetails(
                              name: name,
                              institution: institution,
                              imagepath: imagepath,
                              shortbio: shortbio,
                              description: description,
                              education: education,
                              special: special,
                              exp: exp,
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.info_outline, size: 18, color: purple),
                      label: Text(
                        'Details',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: purple,
                          fontSize: 14,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: purple, width: 1.2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
