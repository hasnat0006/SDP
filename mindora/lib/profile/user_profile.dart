import 'package:client/profile/backend.dart';
import 'package:client/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'edit_profile.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final Map<String, dynamic> userData = {
    'name': 'Loading...',
    'email': 'Loading...',
    'dob': DateTime.now(),
    'gender': 'Not specified',
    'profession': 'Loading...',
    'bio': 'Loading...',
    'profileImage': 'assets/demo_profile.jpg', // Default fallback
    'emergency_contact': null,
  };

  // Mood data structure for easy lookup by mood name
  static const Map<String, Map<String, dynamic>> moodMap = {
    'Happy': {"emoji": "😊", "color": const Color.fromARGB(255, 168, 197, 168)},
    'Sad': {"emoji": "🙁", "color": const Color.fromARGB(255, 238, 145, 64)},
    'Angry': {"emoji": "😠", "color": const Color.fromARGB(255, 221, 87, 82)},
    'Excited': {
      "emoji": "🥳",
      "color": const Color.fromARGB(255, 191, 174, 225),
    },
    'Stressed': {"emoji": "😣", "color": const Color(0xFFF6D55C)},
  };

  // Helper methods to get mood data
  String getMoodEmoji(String moodName) {
    return moodMap[moodName]?['emoji'] ?? '😐';
  }

  Color getMoodColor(String moodName) {
    return moodMap[moodName]?['color'] ?? Colors.grey;
  }

  Map<String, dynamic>? getMoodData(String moodName) {
    return moodMap[moodName];
  }

  List<String> getAllMoodNames() {
    return moodMap.keys.toList();
  }

  List<Map<String, dynamic>> get allMoods {
    return moodMap.entries.map((entry) {
      return {
        'label': entry.key,
        'emoji': entry.value['emoji'],
        'color': entry.value['color'],
      };
    }).toList();
  }

  Map<String, dynamic>? moodData;

  String _userId = '', _userType = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadUserData();

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

  Future<void> loadProfileData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profileData = await ProfileBackend().getUserProfile(
        _userId,
        _userType,
      );
      setState(() {
        userData.addAll(profileData);

        // Parse date string to DateTime if needed
        if (profileData['dob'] is String) {
          try {
            userData['dob'] = DateTime.parse(profileData['dob']);
          } catch (e) {
            print('Error parsing date: $e');
            userData['dob'] = DateTime.now();
          }
        }

        _isLoading = false;
        print('Profile data loaded successfully');
        print(userData);
      });

      loadMoodData();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading profile data: $e');
    }
  }

  Future<void> loadMoodData() async {
    try {
      final moodDataResponse = await ProfileBackend().getUserMoodData(_userId);

      // Check if the response contains meaningful mood data
      if (moodDataResponse.containsKey('mood_status') &&
          moodDataResponse['mood_status'] != null &&
          moodDataResponse['mood_status'].toString().isNotEmpty) {
        setState(() {
          // Transform backend response to match expected format
          final moodStatus = moodDataResponse['mood_status'] ?? 'Happy';
          final currentStreak = moodDataResponse['current_streak'] ?? '0';

          moodData = {
            'recentMood': {
              'emoji': getMoodEmoji(moodStatus),
              'label': moodStatus,
              'color': getMoodColor(moodStatus),
            },
            'moodStreak': int.tryParse(currentStreak.toString()) ?? 0,
          };

          print('Mood data loaded successfully');
          print('Transformed mood data: $moodData');
          print('Original backend response: $moodDataResponse');
        });
      } else {
        print('No valid mood data found in backend response');
        setState(() {
          moodData = null;
        });
      }
    } catch (e) {
      print('Error loading mood data: $e');
      // Keep moodData as null if loading fails
      setState(() {
        moodData = null;
      });
    }
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
      });

      await loadProfileData();
      print('Loaded user data - ID: $_userId, Type: $_userType');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading user data: $e');
    }
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

  void _editProfile() async {
    final updatedUserData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(userData: userData),
      ),
    );

    // If data was returned (profile was saved), update the UI
    if (updatedUserData != null) {
      setState(() {
        // Update individual fields since userData is final
        userData['name'] = updatedUserData['name'];
        userData['email'] = updatedUserData['email'];
        userData['profession'] = updatedUserData['profession'];
        userData['bio'] = updatedUserData['bio'];
        userData['dob'] = updatedUserData['dob'];
        userData['gender'] = updatedUserData['gender'];
        userData['emergency_contact'] = updatedUserData['emergency_contact'];
      });
    }
  }

  ImageProvider _getProfileImage() {
    final profileImageUrl = userData['profileImage'];
    if (profileImageUrl != null &&
        profileImageUrl.toString().startsWith('http')) {
      return NetworkImage(profileImageUrl);
    }

    // Fallback to default asset image
    return AssetImage(profileImageUrl ?? 'assets/demo_profile.jpg');
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
          'Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: const Color(0xFFD1A1E3),
        // rouded corners
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _editProfile,
            icon: const Icon(Icons.edit_outlined),
            tooltip: _isLoading ? 'Loading...' : 'Edit Profile',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading profile...',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Profile Header Card
                      _buildProfileHeader(theme, isDark),
                      const SizedBox(height: 20),

                      // Mood Summary Card - only show if mood data exists
                      if (moodData != null) ...[
                        _buildMoodSummaryCard(theme, isDark),
                        const SizedBox(height: 20),
                      ],

                      // Personal Information Section
                      _buildPersonalInfoSection(theme, isDark),
                      const SizedBox(height: 20),

                      // Bio Section
                      _buildBioSection(theme, isDark),
                      const SizedBox(height: 20),

                      // Emergency Contacts Section
                      _buildEmergencyContactsSection(theme, isDark),
                      const SizedBox(height: 20),

                      // Test Navigation Button
                      // _buildTherapistProfileButton(theme, isDark),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  theme.colorScheme.primary.withOpacity(0.8),
                  theme.colorScheme.secondary.withOpacity(0.6),
                ]
              : [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.secondary.withOpacity(0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          // Profile Image (display only)
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 55,
              backgroundImage: _getProfileImage(),
              onBackgroundImageError: (exception, stackTrace) {
                print('Error loading profile image: $exception');
              },
            ),
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            userData['name'] ?? 'User Name',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildMoodSummaryCard(ThemeData theme, bool isDark) {
    // This method should only be called when moodData is not null
    final mood = moodData!;

    return Container(
      decoration: BoxDecoration(
        color: mood['recentMood']['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: mood['recentMood']['color'].withOpacity(0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: mood['recentMood']['color'].withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              mood['recentMood']['emoji'],
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Mood',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${mood['recentMood']['label']} ${mood['recentMood']['emoji']}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${mood['moodStreak']} day streak!',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: mood['recentMood']['color'],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.trending_up, color: mood['recentMood']['color'], size: 24),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
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
                Icon(
                  Icons.person_outline,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Personal Information',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          _buildInfoTile(
            theme,
            Icons.email_outlined,
            'Email',
            userData['email'] ?? 'Not provided',
          ),
          _buildDivider(theme),
          _buildInfoTile(
            theme,
            Icons.cake_outlined,
            'Date of Birth',
            userData['dob'] != null
                ? DateFormat('MMMM dd, yyyy').format(userData['dob'])
                : 'Not provided',
          ),
          _buildDivider(theme),
          _buildInfoTile(
            theme,
            Icons.calendar_today_outlined,
            'Age',
            userData['dob'] != null
                ? '${_calculateAge(userData['dob'])} years old'
                : 'Not provided',
          ),
          _buildDivider(theme),
          _buildInfoTile(
            theme,
            Icons.person_outline,
            'Gender',
            userData['gender'] ?? 'Not specified',
          ),
          _buildDivider(theme),
          _buildInfoTile(
            theme,
            Icons.work_outline,
            'Profession',
            userData['profession'] ?? 'Not provided',
          ),
        ],
      ),
    );
  }

  Widget _buildBioSection(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
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
              Icon(
                Icons.description_outlined,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'About Me',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            userData['bio'] ?? 'No bio provided',
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.5,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactsSection(ThemeData theme, bool isDark) {
    // Handle null or empty emergency contacts
    final emergencyContactData = userData['emergency_contact'];
    List<String> contacts = [];

    if (emergencyContactData != null) {
      if (emergencyContactData is List) {
        contacts = List<String>.from(
          emergencyContactData.where(
            (contact) => contact != null && contact.toString().isNotEmpty,
          ),
        );
      } else if (emergencyContactData is String &&
          emergencyContactData.isNotEmpty) {
        contacts = [emergencyContactData];
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
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
              TextButton.icon(
                onPressed: _editProfile,
                icon: Icon(
                  Icons.edit,
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
                label: Text(
                  'Edit',
                  style: GoogleFonts.poppins(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (contacts.isEmpty)
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
                      'No emergency contacts added yet. Tap Edit to add contacts.',
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
            ...contacts.asMap().entries.map((entry) {
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
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(
      height: 1,
      thickness: 1,
      color: theme.dividerColor.withOpacity(0.1),
      indent: 56,
      endIndent: 20,
    );
  }
}
