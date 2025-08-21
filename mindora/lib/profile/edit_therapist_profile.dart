import 'package:client/profile/backend.dart';
import 'package:client/services/user_service.dart';
import 'package:client/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class EditTherapistProfilePage extends StatefulWidget {
  final Map<String, dynamic> therapistData;
  final File? currentImage;

  const EditTherapistProfilePage({
    super.key,
    required this.therapistData,
    this.currentImage,
  });

  @override
  State<EditTherapistProfilePage> createState() =>
      _EditTherapistProfilePageState();
}

class _EditTherapistProfilePageState extends State<EditTherapistProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Controllers for text fields
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _bdnController;
  late TextEditingController _instituteController;
  late TextEditingController _shortbioController;
  late TextEditingController _educationController;
  late TextEditingController _descriptionController;
  late TextEditingController _expController;
  late TextEditingController _phoneController;
  late TextEditingController _professionController;

  // State variables
  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  DateTime? _selectedDate;
  String? _selectedGender;
  bool _isAcceptingPatients = false;
  List<String> _specializations = [];
  final TextEditingController _specializationController =
      TextEditingController();

  String _userId = '', _userType = '';
  bool _isLoading = false;

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];

  // Helper method to safely convert any value to string
  String _safeStringValue(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is DateTime) {
      print("WARNING: DateTime found where String expected: $value");
      return value.toIso8601String().split('T')[0]; // Convert to date string
    }
    return value.toString();
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();

    print("=== DEBUGGING THERAPIST DATA TYPES ===");
    widget.therapistData.forEach((key, value) {
      print("$key: $value (${value.runtimeType})");
    });
    print("=== END DEBUGGING ===");

    // Initialize controllers with existing data - with safe type checking
    _nameController = TextEditingController(
      text: _safeStringValue(widget.therapistData['name']),
    );
    _emailController = TextEditingController(
      text: _safeStringValue(widget.therapistData['email']),
    );
    _bdnController = TextEditingController(
      text: _safeStringValue(widget.therapistData['bdn']),
    );
    _instituteController = TextEditingController(
      text: _safeStringValue(widget.therapistData['institute']),
    );
    _shortbioController = TextEditingController(
      text: _safeStringValue(widget.therapistData['shortbio']),
    );
    _educationController = TextEditingController(
      text: _safeStringValue(widget.therapistData['education']),
    );
    _descriptionController = TextEditingController(
      text: _safeStringValue(widget.therapistData['description']),
    );
    _expController = TextEditingController(
      text: _safeStringValue(widget.therapistData['exp']),
    );
    _phoneController = TextEditingController(
      text: _safeStringValue(widget.therapistData['phone_no']),
    );
    _professionController = TextEditingController(
      text: _safeStringValue(widget.therapistData['profession']),
    );

    // Initialize other data
    try {
      _selectedDate = widget.therapistData['dob'] != null
          ? (widget.therapistData['dob'] is String
                ? DateTime.tryParse(widget.therapistData['dob'])
                : widget.therapistData['dob'] is DateTime
                ? widget.therapistData['dob']
                : null)
          : null;
      print("Date initialization successful: $_selectedDate");
    } catch (e) {
      print("Error initializing date: $e");
      _selectedDate = null;
    }
    _selectedGender =
        widget.therapistData['gender'] != null &&
            _genderOptions.contains(widget.therapistData['gender'])
        ? widget.therapistData['gender']
        : null;
    _isAcceptingPatients = widget.therapistData['accept_patient'] ?? false;
    _specializations = List<String>.from(widget.therapistData['special'] ?? []);
    _selectedImage = widget.currentImage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bdnController.dispose();
    _instituteController.dispose();
    _shortbioController.dispose();
    _educationController.dispose();
    _descriptionController.dispose();
    _expController.dispose();
    _phoneController.dispose();
    _professionController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await UserService.getUserData();
      setState(() {
        _userId = userData['userId'] ?? '';
        _userType = userData['userType'] ?? '';
        _isLoading = false;
      });
      print('Loaded user data - ID: $_userId, Type: $_userType');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading user data: $e');
    }
  }

  Future<void> updateTherapistProfile() async {
    print("updateTherapistProfile called");
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      print("Updating therapist profile");
      try {
        String? profileImageUrl;

        // Handle image upload if a new image was selected
        if (_selectedImage != null || _selectedImageBytes != null) {
          print("Uploading new profile image...");
          print("Selected image: ${_selectedImage?.path}");
          print("Selected image bytes: ${_selectedImageBytes?.length}");

          try {
            // Check if Supabase is initialized
            if (!SupabaseService.isInitialized) {
              print("Supabase not initialized. Skipping image upload.");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Image upload disabled. Supabase not configured.',
                  ),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            } else {
              print("Supabase is initialized. Proceeding with upload...");
              // Get current profile image URL for deletion
              final currentImageUrl = widget.therapistData['profileImage'];

              // Upload new image to Supabase based on platform
              if (kIsWeb && _selectedImageBytes != null) {
                print("Uploading image from bytes (Web)...");
                profileImageUrl =
                    await SupabaseService.updateProfileImageFromBytes(
                      _userId,
                      _selectedImageBytes!,
                      currentImageUrl,
                    );
              } else if (_selectedImage != null) {
                print("Uploading image from file (Mobile)...");
                profileImageUrl = await SupabaseService.updateProfileImage(
                  _userId,
                  _selectedImage!,
                  currentImageUrl,
                );
              }

              print("Image uploaded successfully: $profileImageUrl");
            }
          } catch (e) {
            print("Error uploading image: $e");
            // Show error message but continue with profile update
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload image: $e'),
                backgroundColor: Theme.of(context).colorScheme.error,
                duration: Duration(seconds: 5),
              ),
            );
          }
        } else {
          print("No new image selected for upload");
        }

        // Prepare profile data
        String? formattedDate;
        if (_selectedDate != null) {
          try {
            formattedDate = _selectedDate!.toIso8601String().split('T')[0];
            print("Formatted date successfully: $formattedDate");
          } catch (e) {
            print("Error formatting date: $e");
            formattedDate = null;
          }
        }

        final profileData = {
          'name': _nameController.text,
          'email': _emailController.text,
          'bdn': _bdnController.text,
          'institute': _instituteController.text,
          'profession': _professionController.text,
          'shortbio': _shortbioController.text,
          'education': _educationController.text,
          'description': _descriptionController.text,
          'exp': _expController.text, // Keep as text (e.g., "10 years")
          'phone_no': _phoneController.text,
          'special': _specializations,
          'accept_patient': _isAcceptingPatients,
          'dob': formattedDate,
          'gender': _selectedGender,
        };

        print("Profile data being sent to backend:");
        profileData.forEach((key, value) {
          print("$key: $value (${value.runtimeType})");
        });

        // Update profile with or without new image
        print("Calling ProfileBackend().updateUserProfile...");
        final response1 = await ProfileBackend().updateUserProfile(
          _userId,

          _userType,
          profileData,
        );
        print("Backend response1: $response1");

        String s = "";
        Map<String, dynamic>? response2;
        if (profileImageUrl != null) {
          print("Calling ProfileBackend().updateUserProfileWithImage...");
          response2 = await ProfileBackend().updateUserProfileWithImage(
            _userId,
            _userType,
            profileImageUrl,
          );
          print("Backend response2: $response2");
          if (response2['success'] == true) {
            s += "Profile Image";
          }
        }

        if (response1['success'] == true) {
          // Update the local therapistData with the new values
          widget.therapistData['name'] = _nameController.text;
          widget.therapistData['email'] = _emailController.text;
          widget.therapistData['bdn'] = _bdnController.text;
          widget.therapistData['institute'] = _instituteController.text;
          widget.therapistData['profession'] = _professionController.text;
          widget.therapistData['shortbio'] = _shortbioController.text;
          widget.therapistData['education'] = _educationController.text;
          widget.therapistData['description'] = _descriptionController.text;
          widget.therapistData['exp'] = _expController.text; // Keep as text
          widget.therapistData['phone_no'] = _phoneController.text;
          widget.therapistData['special'] = _specializations;
          widget.therapistData['accept_patient'] = _isAcceptingPatients;
          widget.therapistData['dob'] = formattedDate;
          widget.therapistData['gender'] = _selectedGender;

          // Update profile image URL if a new one was uploaded
          if (profileImageUrl != null) {
            widget.therapistData['profileImage'] = profileImageUrl;
          }

          s += s.isNotEmpty ? ", data" : "data";

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$s updated successfully!')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to update profile. ${response1['message'] ?? 'Unknown error'}',
              ),
            ),
          );
        }
      } catch (e) {
        print('Error updating profile: $e');
        print('Error type: ${e.runtimeType}');
        if (e.toString().contains('DateTime')) {
          print('DateTime-related error detected!');
          print('_selectedDate value: $_selectedDate');
          print('_selectedDate type: ${_selectedDate.runtimeType}');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
        print('Image selected: ${image.path}');

        if (kIsWeb) {
          // For web, read the image as bytes properly
          try {
            final bytes = await image.readAsBytes();
            print('Image bytes read successfully: ${bytes.length} bytes');
            setState(() {
              _selectedImageBytes = bytes;
              _selectedImage = null; // Clear file reference for web
            });
          } catch (e) {
            print('Error reading image bytes: $e');
            throw Exception('Failed to read image data');
          }
        } else {
          // For mobile platforms, use File
          setState(() {
            _selectedImage = File(image.path);
            _selectedImageBytes = null; // Clear bytes reference for mobile
          });
          print('Image file set: ${_selectedImage?.path}');
        }

        if (mounted) {
          Navigator.pop(context); // Close the bottom sheet

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile picture selected! Save to upload.'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Error in _selectImage: $e');
      if (mounted) {
        Navigator.pop(context); // Close the bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _selectedImageBytes = null;
    });
    Navigator.pop(context); // Close the bottom sheet

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile picture removed'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  ImageProvider _getDisplayImage() {
    // If we have a selected image, use it
    if (kIsWeb && _selectedImageBytes != null) {
      return MemoryImage(_selectedImageBytes!);
    } else if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    }

    // Otherwise, use the profile image from therapist data
    final profileImageUrl = widget.therapistData['profileImage'];
    if (profileImageUrl != null &&
        profileImageUrl.toString().startsWith('http')) {
      return NetworkImage(profileImageUrl);
    }

    // Fallback to default asset image
    return AssetImage(profileImageUrl ?? 'assets/therapist.png');
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1990),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4A148C),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addSpecialization() {
    if (_specializationController.text.isNotEmpty) {
      setState(() {
        _specializations.add(_specializationController.text.trim());
        _specializationController.clear();
      });
    }
  }

  void _removeSpecialization(String specialization) {
    setState(() {
      _specializations.remove(specialization);
    });
  }

  void _saveProfile() async {
    print("_saveProfile method called");

    // Debug: Check current field values
    print("Current field values:");
    print("Name: '${_nameController.text}'");
    print("Email: '${_emailController.text}'");
    print("BDN: '${_bdnController.text}'");
    print("Phone: '${_phoneController.text}'");
    print("Institute: '${_instituteController.text}'");
    print("Profession: '${_professionController.text}'");
    print("Experience: '${_expController.text}'");
    print("Description: '${_descriptionController.text}'");
    print("Short Bio: '${_shortbioController.text}'");
    print("Education: '${_educationController.text}'");
    print("Gender: '$_selectedGender'");
    print("Date: '$_selectedDate'");

    if (_formKey.currentState!.validate()) {
      print("Form validation passed");
      print("Calling updateTherapistProfile()");
      await updateTherapistProfile();

      // Pass the updated therapistData back to the parent
      Navigator.pop(context, {
        'data': widget.therapistData,
        'image': _selectedImage,
      });
    } else {
      print("Form validation failed");

      // Show a SnackBar to inform the user about validation errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please fill in all required fields correctly',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: const Color(0xFF4A148C),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Image Section
                  _buildProfileImageSection(),
                  const SizedBox(height: 24),

                  // Basic Information
                  _buildBasicInfoSection(),
                  const SizedBox(height: 20),

                  // Professional Information
                  _buildProfessionalInfoSection(),
                  const SizedBox(height: 20),

                  // Specializations
                  _buildSpecializationsSection(),
                  const SizedBox(height: 20),

                  // Status Settings
                  _buildStatusSection(),
                  const SizedBox(height: 20),

                  // Bio Section
                  _buildBioSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A148C)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileImageSection() {
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
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF4A148C).withOpacity(0.3),
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 55,
                  backgroundImage: _getDisplayImage(),
                ),
              ),
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
              if (_selectedImage != null ||
                  widget.therapistData['profileImage'] != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Tap the camera icon to change your profile picture',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                color: Color(0xFFBA68C8),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Basic Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Name
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Email
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Date of Birth
          InkWell(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cake, color: Colors.grey),
                  const SizedBox(width: 12),
                  Text(
                    _selectedDate != null
                        ? DateFormat('MMMM dd, yyyy').format(_selectedDate!)
                        : 'Select Date of Birth',
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedDate != null
                          ? Colors.black87
                          : Colors.grey,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Gender
          DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: const InputDecoration(
              labelText: 'Gender',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            items: _genderOptions.map((String gender) {
              return DropdownMenuItem<String>(
                value: gender,
                child: Text(gender),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedGender = newValue;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a gender';
              }
              return null;
            },
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          const SizedBox(height: 20),

          // Profession
          TextFormField(
            controller: _professionController,
            decoration: const InputDecoration(
              labelText: 'Profession/Title',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.work),
              hintText: 'e.g., Clinical Psychologist, Psychiatrist',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your profession';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // BDN (Medical Registration Number)
          TextFormField(
            controller: _bdnController,
            decoration: const InputDecoration(
              labelText: 'BDN/Medical Registration Number',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.badge),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your BMDC number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Phone Number
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Institute/Workplace
          TextFormField(
            controller: _instituteController,
            decoration: const InputDecoration(
              labelText: 'Institute/Workplace',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.business),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your workplace';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Years of Experience
          TextFormField(
            controller: _expController,
            decoration: const InputDecoration(
              labelText: 'Experience (e.g., "10 years")',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.timeline),
              hintText: 'e.g., 5 years, 2+ years, 10+ years',
            ),
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your experience';
              }
              return null;
            },
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
      padding: const EdgeInsets.all(20),
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
          const SizedBox(height: 20),

          // Add specialization field
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _specializationController,
                  decoration: const InputDecoration(
                    labelText: 'Add Specialization',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.add),
                  ),
                  onFieldSubmitted: (_) => _addSpecialization(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addSpecialization,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A148C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                child: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Display specializations
          if (_specializations.isNotEmpty) ...[
            const Text(
              'Current Specializations:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _specializations
                  .map(
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            specialization,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => _removeSpecialization(specialization),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.settings_outlined,
                color: Color(0xFFBA68C8),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Status Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Accepting Patients Status
          SwitchListTile(
            title: const Text(
              'Accepting New Patients',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
            subtitle: const Text(
              'Show availability to new patients',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            value: _isAcceptingPatients,
            onChanged: (bool value) {
              setState(() {
                _isAcceptingPatients = value;
              });
            },
            activeColor: const Color(0xFF4A148C),
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
      padding: const EdgeInsets.all(20),
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
          const SizedBox(height: 20),

          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Professional Description',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 5,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your professional description';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Short Bio
          TextFormField(
            controller: _shortbioController,
            decoration: const InputDecoration(
              labelText: 'Short Bio',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
            validator: (value) {
              // Make short bio optional
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Education
          TextFormField(
            controller: _educationController,
            decoration: const InputDecoration(
              labelText: 'Education',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            validator: (value) {
              // Make education optional
              return null;
            },
          ),
        ],
      ),
    );
  }
}
