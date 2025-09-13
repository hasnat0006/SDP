import 'package:client/forum/backend.dart';
import 'package:client/services/user_service.dart';
import 'package:flutter/material.dart';
import 'forum_models.dart';

class CreatePostPage extends StatefulWidget {
  final Function() onPostCreated;
  final String? initialContent;

  const CreatePostPage({
    super.key,
    required this.onPostCreated,
    this.initialContent,
  });

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage>
    with TickerProviderStateMixin {
  final TextEditingController _contentController = TextEditingController();
  MoodType? _selectedMood;
  bool _isPosting = false;

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  String _userId = '';
  String _userType = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();

    // Set initial content if provided
    if (widget.initialContent != null) {
      _contentController.text = widget.initialContent!;
    }

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await UserService.getUserData();
      _userId = userData['userId'] ?? '';
      _userType = userData['userType'] ?? '';
      print('Loaded user data - ID: $_userId, Type: $_userType');
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _createPost() async {
    if (_contentController.text.trim().isEmpty || _selectedMood == null) {
      _showSnackBar('Please write your thoughts and select a mood');
      return;
    }

    setState(() {
      _isPosting = true;
    });

    // Simulate posting delay
    await Future.delayed(const Duration(seconds: 1));

    final posting = await ForumBackend().post(
      content: _contentController.text.trim(),
      mood: _selectedMood!.displayName,
      userId: _userId,
    );

    if (posting['success']) {
      setState(() {
        _isPosting = false;
      });

      // Call the callback to refresh the forum page
      widget.onPostCreated();

      Navigator.pop(context);
      _showSnackBar('Your post has been shared anonymously ✨');
    } else {
      setState(() {
        _isPosting = false;
      });
      _showSnackBar('Failed to create post: ${posting['message']}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.deepPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Share Your Thoughts',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAnonymousNotice(),
              const SizedBox(height: 24),
              _buildContentInput(),
              const SizedBox(height: 24),
              _buildMoodSelector(),
              const SizedBox(height: 32),
              _buildPostButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnonymousNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF667EEA).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF667EEA).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.security, color: Colors.deepPurple, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Anonymous Posting',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Your identity is completely protected. Share freely.',
                  style: TextStyle(color: Color(0xFF4A5568), fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What\'s on your mind?',
              style: TextStyle(
                color: Color(0xFF2D3748),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: 6,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Share your thoughts, feelings, or experiences...',
                hintStyle: const TextStyle(
                  color: Color(0xFF718096),
                  fontSize: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF667EEA),
                    width: 2,
                  ),
                ),
              ),
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Color(0xFF2D3748),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How are you feeling?',
              style: TextStyle(
                color: Color(0xFF2D3748),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: MoodType.values.map((mood) {
                final isSelected = _selectedMood == mood;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMood = mood;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? mood.color.withOpacity(0.15)
                          : const Color(0xFFF7FAFC),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected
                            ? mood.color
                            : const Color(0xFFE2E8F0),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(mood.emoji, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(
                          mood.displayName,
                          style: TextStyle(
                            color: isSelected
                                ? mood.color
                                : const Color(0xFF4A5568),
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostButton() {
    return SizedBox(
      width: double.infinity,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ElevatedButton(
          onPressed: _isPosting ? null : _createPost,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: _isPosting
              ? const SizedBox(
                  height: 15,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Share Anonymously',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
        ),
      ),
    );
  }
}
