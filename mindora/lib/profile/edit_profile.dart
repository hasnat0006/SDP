import 'package:client/profile/backend.dart';
import 'package:client/services/user_service.dart';
import 'package:client/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:typed_data';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfilePage({super.key, required this.userData});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _professionController;
  late TextEditingController _bioController;
  late DateTime _selectedDate;
  String _selectedGender = 'Female';
  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  List<String> _emergencyContacts = [];

  final List<String> _genderOptions = ['Male', 'Female', 'Prefer not to say'];

  String _userId = '', _userType = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _nameController = TextEditingController(text: widget.userData['name']);
    _emailController = TextEditingController(text: widget.userData['email']);
    _professionController = TextEditingController(
      text: widget.userData['profession'],
    );
    _bioController = TextEditingController(text: widget.userData['bio']);
    _selectedDate = widget.userData['dob'];
    _selectedGender = widget.userData['gender'];
    _emergencyContacts = List<String>.from(
      widget.userData['emergency_contact'] ?? [],
    );
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
        _isLoading = false; // Set loading to false on success
      });
      print('Loaded user data - ID: $_userId, Type: $_userType');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading user data: $e');
    }
  }

  Future<void> _debugSupabaseConnection() async {
    print('🧪 Debug: Testing Supabase connection...');

    if (!SupabaseService.isInitialized) {
      print('❌ Debug: Supabase not initialized');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Supabase not initialized. Check configuration.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final client = SupabaseService.client;
      final buckets = await client.storage.listBuckets();
      print('✅ Debug: Found ${buckets.length} buckets');

      final hasProfileBucket = buckets.any((b) => b.name == 'profile-images');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            hasProfileBucket
                ? 'Supabase connected! profile-images bucket found.'
                : 'Supabase connected but profile-images bucket missing!',
          ),
          backgroundColor: hasProfileBucket ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      print('❌ Debug: Supabase error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Supabase error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> updateUserProfileInformation() async {
    print("updateUserProfileInformation called");
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      print("i am edit");
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
              final currentImageUrl = widget.userData['profileImage'];

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
                duration: Duration(seconds: 5), // Show longer for debugging
              ),
            );
            // Don't set profileImageUrl to null, leave it as is
            // This way profile update can still proceed without the image
          }
        } else {
          print("No new image selected for upload");
        }

        // Prepare profile data
        final profileData = {
          'name': _nameController.text,
          'email': _emailController.text,
          'profession': _professionController.text,
          'bio': _bioController.text,
          'dob': _selectedDate.toIso8601String(),
          'gender': _selectedGender,
          'emergency_contact': _emergencyContacts,
        };

        // Update profile with or without new image
        final response1 = await ProfileBackend().updateUserProfile(
          _userId,
          _userType,
          profileData,
        );
        dynamic response2;
        if (profileImageUrl != null) {
          response2 = await ProfileBackend().updateUserProfileWithImage(
            _userId,
            _userType,
            profileImageUrl,
          );
        }

        if (response1['success'] && response2['success']) {
          // Update the local userData with the new values
          widget.userData['name'] = _nameController.text;
          widget.userData['email'] = _emailController.text;
          widget.userData['profession'] = _professionController.text;
          widget.userData['bio'] = _bioController.text;
          widget.userData['dob'] = _selectedDate;
          widget.userData['gender'] = _selectedGender;
          widget.userData['emergency_contact'] = _emergencyContacts;

          // Update profile image URL if a new one was uploaded
          if (profileImageUrl != null) {
            widget.userData['profileImage'] = profileImageUrl;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully!')),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to update profile.')));
        }
      } catch (e) {
        print('Error updating profile: $e');
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _professionController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
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

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
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
                        color: Theme.of(context).dividerColor.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Change Profile Picture',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildImageSourceOption(
                          context,
                          Icons.camera_alt,
                          'Camera',
                          () => _selectImage(ImageSource.camera),
                        ),
                        _buildImageSourceOption(
                          context,
                          Icons.photo_library,
                          'Gallery',
                          () => _selectImage(ImageSource.gallery),
                        ),
                        if (_selectedImage != null ||
                            _selectedImageBytes != null)
                          _buildImageSourceOption(
                            context,
                            Icons.delete,
                            'Remove',
                            _removeImage,
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

  Widget _buildImageSourceOption(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
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

    // Otherwise, use the profile image from user data
    return _getProfileImage();
  }

  ImageProvider _getProfileImage() {
    final profileImageUrl = widget.userData['profileImage'];
    if (profileImageUrl != null &&
        profileImageUrl.toString().startsWith('http')) {
      return NetworkImage(profileImageUrl);
    }

    // Fallback to default asset image
    return AssetImage(profileImageUrl ?? 'assets/nabiha.jpeg');
  }

  void _saveProfile() async {
    print("_saveProfile method called");
    if (_formKey.currentState!.validate()) {
      print("Form validation passed");
      print("Calling updateUserProfileInformation()");
      await updateUserProfileInformation();

      // Pass the updated userData back to the parent
      Navigator.pop(context, widget.userData);
    } else {
      print("Form validation failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Debug button - remove in production
          IconButton(
            onPressed: _debugSupabaseConnection,
            icon: Icon(Icons.bug_report),
            tooltip: 'Debug Supabase',
          ),
          TextButton(
            onPressed: _isLoading
                ? null
                : () {
                    print("Save button pressed in AppBar");
                    _saveProfile();
                  },
            child: Text(
              'Save',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Image Section
              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.3),
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
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                        child: IconButton(
                          onPressed: _pickImage,
                          icon: Icon(
                            Icons.camera_alt,
                            color: theme.colorScheme.onPrimary,
                            size: 18,
                          ),
                          iconSize: 18,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Form Fields
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date of Birth Field
              _buildDateField(theme),
              const SizedBox(height: 16),

              // Gender Dropdown
              _buildGenderDropdown(theme),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _professionController,
                label: 'Profession',
                icon: Icons.work_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your profession';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _bioController,
                label: 'Bio',
                icon: Icons.description_outlined,
                maxLines: 3,
                validator: (value) {
                  if (value != null && value.length > 150) {
                    return 'Bio should be less than 150 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Emergency Contacts Section
              _buildEmergencyContactsSection(theme),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          print("Save button pressed at bottom");
                          _saveProfile();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.onPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Saving...',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Save Changes',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        filled: true,
        fillColor: theme.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildDateField(ThemeData theme) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.cake_outlined, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date of Birth',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    DateFormat('MMMM dd, yyyy').format(_selectedDate),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderDropdown(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        decoration: InputDecoration(
          labelText: 'Gender',
          labelStyle: GoogleFonts.poppins(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          prefixIcon: Icon(
            Icons.person_outline,
            color: theme.colorScheme.primary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        style: GoogleFonts.poppins(color: theme.colorScheme.onSurface),
        dropdownColor: theme.cardColor,
        items: _genderOptions.map((String gender) {
          return DropdownMenuItem<String>(
            value: gender,
            child: Text(gender, style: GoogleFonts.poppins()),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedGender = newValue;
            });
          }
        },
      ),
    );
  }

  Widget _buildEmergencyContactsSection(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.emergency_outlined,
                    color: Colors.red[600],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Emergency Contacts',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: _emergencyContacts.length < 2
                    ? _addEmergencyContact
                    : null,
                icon: Icon(
                  Icons.add,
                  color: _emergencyContacts.length < 2
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.3),
                ),
                tooltip: _emergencyContacts.length < 2
                    ? 'Add Emergency Contact'
                    : 'Maximum 2 contacts allowed',
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_emergencyContacts.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No emergency contacts added yet. Tap + to add contacts (max 2).',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ..._emergencyContacts.asMap().entries.map((entry) {
              int index = entry.key;
              String contact = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!, width: 1),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.phone, color: Colors.red[700], size: 20),
                  ),
                  title: Text(
                    'Contact ${index + 1}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.red[700],
                    ),
                  ),
                  subtitle: Text(
                    contact,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red[800],
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _editEmergencyContact(index),
                        icon: Icon(
                          Icons.edit,
                          color: Colors.red[600],
                          size: 20,
                        ),
                        tooltip: 'Edit Contact',
                      ),
                      IconButton(
                        onPressed: () => _removeEmergencyContact(index),
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red[600],
                          size: 20,
                        ),
                        tooltip: 'Remove Contact',
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  void _addEmergencyContact() {
    _showContactInputDialog(
      title: 'Add Emergency Contact',
      initialValue: '',
      onSave: (contact) {
        if (contact.isNotEmpty && contact.trim().isNotEmpty) {
          setState(() {
            _emergencyContacts.add(contact.trim());
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Emergency contact added successfully'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
    );
  }

  void _editEmergencyContact(int index) {
    _showContactInputDialog(
      title: 'Edit Emergency Contact',
      initialValue: _emergencyContacts[index],
      onSave: (contact) {
        if (contact.isNotEmpty && contact.trim().isNotEmpty) {
          setState(() {
            _emergencyContacts[index] = contact.trim();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Emergency contact updated successfully'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
    );
  }

  void _removeEmergencyContact(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Remove Emergency Contact',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Are you sure you want to remove this emergency contact?',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _emergencyContacts.removeAt(index);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Emergency contact removed'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              child: Text(
                'Remove',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showContactInputDialog({
    required String title,
    required String initialValue,
    required Function(String) onSave,
  }) {
    final TextEditingController controller = TextEditingController(
      text: initialValue,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'e.g., +1 (555) 123-4567',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                style: GoogleFonts.poppins(),
              ),
              const SizedBox(height: 16),
              Text(
                'Enter a valid phone number for emergency contact',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final contact = controller.text.trim();
                if (contact.isNotEmpty) {
                  onSave(contact);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Please enter a valid phone number'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Save',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
      },
    );
  }
}
