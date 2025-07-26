import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'edit_therapist_profile.dart';

class TherapistProfilePage extends StatefulWidget {
  const TherapistProfilePage({super.key});

  @override
  State<TherapistProfilePage> createState() => _TherapistProfilePageState();
}

class _TherapistProfilePageState extends State<TherapistProfilePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  // Therapist data - in a real app, this would come from a backend
  Map<String, dynamic> therapistData = {
    'name': 'Dr. Samira Rahman',
    'username': '@dr_samira',
    'email': 'dr.samira@therapyhub.com',
    'dob': DateTime(1985, 8, 22),
    'gender': 'Female',
    'profession': 'Clinical Psychologist',
    'bio':
        'Dedicated to helping individuals overcome mental health challenges through evidence-based therapy. Specialized in cognitive behavioral therapy and trauma recovery.',
    'profileImage': 'assets/therapist.png',
    'bmdcNumber': 'BMDC-45789',
    'contactNumber': '+880 1712-345678',
    'clinicName': 'MindWell Psychology Center',
    'experience': 8,
    'specializations': [
      'Anxiety Disorders',
      'Depression',
      'Trauma Therapy',
      'CBT',
      'PTSD',
      'Stress Management',
    ],
    'isVerified': true,
    'isAcceptingPatients': true,
    'rating': 4.8,
    'totalPatients': 156,
  };

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  int _calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  void _editProfile() {
    // Navigate to edit profile page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTherapistProfilePage(
          therapistData: therapistData,
          currentImage: _selectedImage,
        ),
      ),
    ).then((result) {
      if (result != null) {
        // Update the profile data with the returned data
        setState(() {
          therapistData = result['data'];
          if (result['image'] != null) {
            _selectedImage = result['image'];
          }
        });
      }
    });
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Change Profile Picture',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildImageSourceOption(
                          Icons.camera_alt,
                          'Camera',
                          () => _selectImage(ImageSource.camera),
                        ),
                        _buildImageSourceOption(
                          Icons.photo_library,
                          'Gallery',
                          () => _selectImage(ImageSource.gallery),
                        ),
                        _buildImageSourceOption(
                          Icons.folder,
                          'Files',
                          _selectImageFromFiles,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
    }
  }

  Future<void> _selectImageFromFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedImage = File(result.files.single.path!);
        });
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
    }
  }

  Widget _buildImageSourceOption(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF4A148C).withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF4A148C).withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFFBA68C8), size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Therapist Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: const Color(0xFFD1A1E3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _editProfile,
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profile',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header Card
                _buildProfileHeader(),
                const SizedBox(height: 20),

                // Status and Stats Card
                _buildStatusCard(),
                const SizedBox(height: 20),

                // Personal Information Section
                _buildPersonalInfoSection(),
                const SizedBox(height: 20),

                // Professional Information Section
                _buildProfessionalInfoSection(),
                const SizedBox(height: 20),

                // Specializations Section
                _buildSpecializationsSection(),
                const SizedBox(height: 20),

                // Bio Section
                _buildBioSection(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.only(bottom: 80),
      //   child: FloatingActionButton.extended(
      //     onPressed: _editProfile,
      //     icon: const Icon(Icons.edit),
      //     label: const Text(
      //       'Edit Profile',
      //       style: TextStyle(
      //         fontWeight: FontWeight.w500,
      //         fontFamily: 'Poppins',
      //       ),
      //     ),
      //     backgroundColor: const Color(0xFF4A148C),
      //     foregroundColor: Colors.white,
      //     elevation: 6,
      //     extendedPadding: const EdgeInsets.symmetric(
      //       horizontal: 20,
      //       vertical: 10,
      //     ),
      //   ),
      // ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4A148C).withOpacity(0.2),
            const Color(0xFF7B1FA2).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A148C).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Profile Image with Edit Button and Verified Badge
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 55,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!) as ImageProvider
                      : AssetImage(therapistData['profileImage']),
                ),
              ),
              // Verified Badge
              if (therapistData['isVerified'])
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              // Edit Button
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A148C),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: IconButton(
                    onPressed: _pickImage,
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                    iconSize: 18,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Name and Verified Status
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                therapistData['name'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
              if (therapistData['isVerified']) ...[
                const SizedBox(width: 8),
                const Icon(Icons.verified, color: Color(0xFF4CAF50), size: 20),
              ],
            ],
          ),
          const SizedBox(height: 4),

          // Username
          Text(
            therapistData['username'],
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFFBA68C8),
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),

          // Profession
          Text(
            therapistData['profession'],
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4A148C).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Availability Status
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: therapistData['isAcceptingPatients']
                        ? const Color(0xFF4CAF50).withOpacity(0.2)
                        : const Color(0xFFF44336).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    therapistData['isAcceptingPatients']
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: therapistData['isAcceptingPatients']
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFF44336),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  therapistData['isAcceptingPatients']
                      ? 'Accepting Patients'
                      : 'Not Available',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Rating
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Color(0xFFFF9800),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${therapistData['rating']} Rating',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Total Patients
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A148C).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.people,
                    color: Color(0xFFBA68C8),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${therapistData['totalPatients']} Patients',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  color: Color(0xFFBA68C8),
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          _buildInfoTile(Icons.email_outlined, 'Email', therapistData['email']),
          _buildDivider(),
          _buildInfoTile(
            Icons.cake_outlined,
            'Date of Birth',
            DateFormat('MMMM dd, yyyy').format(therapistData['dob']),
          ),
          _buildDivider(),
          _buildInfoTile(
            Icons.calendar_today_outlined,
            'Age',
            '${_calculateAge(therapistData['dob'])} years old',
          ),
          _buildDivider(),
          _buildInfoTile(
            Icons.person_outline,
            'Gender',
            therapistData['gender'],
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.work_outline,
                  color: Color(0xFFBA68C8),
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Professional Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          _buildInfoTile(
            Icons.badge_outlined,
            'BMDC Number',
            therapistData['bmdcNumber'],
          ),
          _buildDivider(),
          _buildInfoTile(
            Icons.phone_outlined,
            'Contact Number',
            therapistData['contactNumber'],
          ),
          _buildDivider(),
          _buildInfoTile(
            Icons.business_outlined,
            'Clinic/Workplace',
            therapistData['clinicName'],
          ),
          _buildDivider(),
          _buildInfoTile(
            Icons.timeline_outlined,
            'Years of Experience',
            '${therapistData['experience']} years',
          ),
        ],
      ),
    );
  }

  Widget _buildSpecializationsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.psychology_outlined,
                color: Color(0xFFBA68C8),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Specializations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: therapistData['specializations']
                .map<Widget>(
                  (specialization) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF4A148C).withOpacity(0.3),
                          const Color(0xFF7B1FA2).withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFBA68C8).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      specialization,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBioSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.description_outlined,
                color: Color(0xFFBA68C8),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'About Me',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            therapistData['bio'],
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black87.withOpacity(0.8),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4A148C).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFFBA68C8), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.withOpacity(0.3),
      indent: 56,
      endIndent: 20,
    );
  }
}
