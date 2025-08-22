import 'package:client/forum/backend.dart';
import 'package:client/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'forum_models.dart';
import 'saved_posts.dart';
import 'create_post.dart';
import 'my_posts.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _shareController = TextEditingController();
  final FocusNode _shareFocusNode = FocusNode();

  List<ForumPost> posts = [];
  List<ForumPost> savedPosts = [];
  String selectedMoodFilter = 'All';
  bool _isLoading = true;
  Set<String> _likingPosts = {}; // Track posts being liked/unliked
  Set<String> _savingPosts = {}; // Track posts being saved/unsaved

  String _userId = '', _userType = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _shareController.dispose();
    _shareFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await UserService.getUserData();
      setState(() {
        _userId = userData['userId'] ?? '';
        _userType = userData['userType'] ?? '';
      });

      _loadAllData();
      print('Loaded user data - ID: $_userId, Type: $_userType');
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final post = await ForumBackend().getAllPosts(_userId);
      setState(() {
        posts = post;
        _isLoading = false;
      });
      savedPosts.clear();
      setState(() {
        for (var post in posts) {
          if (post.isSaved) {
            savedPosts.add(post);
          }
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<ForumPost> get filteredPosts {
    if (selectedMoodFilter == 'All') {
      return posts;
    }
    return posts
        .where(
          (post) =>
              post.mood.name.toLowerCase() == selectedMoodFilter.toLowerCase(),
        )
        .toList();
  }

  void _toggleLike(String postId) async {
    final postIndex = posts.indexWhere((post) => post.id == postId);
    if (postIndex == -1) return;

    // Prevent multiple rapid taps
    if (_likingPosts.contains(postId)) return;

    setState(() {
      _likingPosts.add(postId);
    });

    final wasLiked = posts[postIndex].isLiked;

    try {
      Map<String, dynamic> response;

      if (wasLiked) {
        // Remove like
        response = await ForumBackend().removeLike(
          postId: postId,
          userId: _userId,
        );
      } else {
        // Add like
        response = await ForumBackend().addLike(
          postId: postId,
          userId: _userId,
        );
      }

      if (response['success']) {
        setState(() {
          posts[postIndex].isLiked = !wasLiked;
          posts[postIndex].likes += wasLiked ? -1 : 1;
        });
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? 'Failed to update like status',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error toggling like: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update like status'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _likingPosts.remove(postId);
      });
    }
  }

  void _toggleSave(String postId) async {
    final postIndex = posts.indexWhere((post) => post.id == postId);
    if (postIndex == -1) return;

    // Prevent multiple rapid taps
    if (_savingPosts.contains(postId)) return;

    setState(() {
      _savingPosts.add(postId);
    });

    final wasLiked = posts[postIndex].isSaved;

    try {
      Map<String, dynamic> response;

      if (wasLiked) {
        // Remove save
        response = await ForumBackend().removeSave(
          postId: postId,
          userId: _userId,
        );
      } else {
        // Add save
        response = await ForumBackend().addSave(
          postId: postId,
          userId: _userId,
        );
      }

      if (response['success']) {
        setState(() {
          posts[postIndex].isSaved = !wasLiked;

          if (posts[postIndex].isSaved) {
            savedPosts.add(posts[postIndex]);
          } else {
            savedPosts.removeWhere((post) => post.id == postId);
          }
        });
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? 'Failed to update save status',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error toggling save: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update save status'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _savingPosts.remove(postId);
      });
    }
  }

  void _addNewPost(ForumPost newPost) {
    setState(() {
      posts.insert(0, newPost);
    });
  }

  void _quickShare() {
    // Simply navigate to create post page when tapped
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePostPage(onPostCreated: _addNewPost),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Community Forum',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        backgroundColor: const Color(0xFFD1A1E3),
        // rounded corners
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SavedPostsPage(savedPosts: savedPosts),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyPostsPage()),
              );
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildShareBox(),
            _buildMoodFilter(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF667EEA),
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await Future.delayed(const Duration(seconds: 1));
                        _loadAllData();
                      },
                      child: filteredPosts.isEmpty
                          ? const Center(
                              child: Text(
                                'No posts available',
                                style: TextStyle(
                                  color: Color(0xFF718096),
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredPosts.length,
                              itemBuilder: (context, index) {
                                return PostCard(
                                  post: filteredPosts[index],
                                  onLike: _toggleLike,
                                  onSave: _toggleSave,
                                  isLiking: _likingPosts.contains(
                                    filteredPosts[index].id,
                                  ),
                                  isSaving: _savingPosts.contains(
                                    filteredPosts[index].id,
                                  ),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareBox() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _shareController,
              focusNode: _shareFocusNode,
              decoration: const InputDecoration(
                hintText: 'Share something with us...',
                hintStyle: TextStyle(color: Color(0xFF718096), fontSize: 16),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              style: const TextStyle(color: Color(0xFF2D3748), fontSize: 16),
              maxLines: 3,
              minLines: 1,
              onTap: _quickShare,
              readOnly: true,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _quickShare,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodFilter() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterChip('All'),
          ...MoodType.values.map((mood) => _buildFilterChip(mood.displayName)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String mood) {
    final isSelected = selectedMoodFilter == mood;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          mood,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF4A5568),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedMoodFilter = mood;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF667EEA),
        checkmarkColor: Colors.white,
        side: BorderSide(
          color: isSelected ? const Color(0xFF667EEA) : const Color(0xFFE2E8F0),
        ),
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final ForumPost post;
  final Function(String) onLike;
  final Function(String) onSave;
  final bool isLiking;
  final bool isSaving;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onSave,
    this.isLiking = false,
    this.isSaving = false,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _animateButton() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            Row(
              children: [
                _buildMoodBadge(),
                const Spacer(),
                Text(
                  _formatTimestamp(widget.post.timestamp),
                  style: const TextStyle(
                    color: Color(0xFF718096),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.post.content,
              style: const TextStyle(
                color: Color(0xFF2D3748),
                fontSize: 16,
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildLikeButton(),
                const SizedBox(width: 16),
                _buildSaveButton(),
                const Spacer(),
                if (widget.post.likes > 0)
                  Text(
                    '${widget.post.likes} ${widget.post.likes == 1 ? 'like' : 'likes'}',
                    style: const TextStyle(
                      color: Color(0xFF718096),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: widget.post.mood.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.post.mood.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.post.mood.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            widget.post.mood.displayName,
            style: TextStyle(
              color: widget.post.mood.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLikeButton() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: widget.isLiking
            ? null
            : () {
                _animateButton();
                widget.onLike(widget.post.id);
              },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.post.isLiked
                ? const Color(0xFFE53E3E).withOpacity(0.1)
                : const Color(0xFFF7FAFC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.post.isLiked
                  ? const Color(0xFFE53E3E).withOpacity(0.3)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.isLiking
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFE53E3E),
                        ),
                      ),
                    )
                  : Icon(
                      widget.post.isLiked
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: widget.post.isLiked
                          ? const Color(0xFFE53E3E)
                          : const Color(0xFF718096),
                      size: 18,
                    ),
              const SizedBox(width: 6),
              Text(
                'Like',
                style: TextStyle(
                  color: widget.post.isLiked
                      ? const Color(0xFFE53E3E)
                      : const Color(0xFF718096),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: widget.isSaving
          ? null
          : () {
              widget.onSave(widget.post.id);
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: widget.post.isSaved
              ? const Color(0xFF3182CE).withOpacity(0.1)
              : const Color(0xFFF7FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.post.isSaved
                ? const Color(0xFF3182CE).withOpacity(0.3)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF3182CE),
                      ),
                    ),
                  )
                : Icon(
                    widget.post.isSaved
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: widget.post.isSaved
                        ? const Color(0xFF3182CE)
                        : const Color(0xFF718096),
                    size: 18,
                  ),
            const SizedBox(width: 6),
            Text(
              'Save',
              style: TextStyle(
                color: widget.post.isSaved
                    ? const Color(0xFF3182CE)
                    : const Color(0xFF718096),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd').format(timestamp);
    }
  }
}
