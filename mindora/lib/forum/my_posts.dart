import 'package:client/forum/backend.dart';
import 'package:client/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'forum_models.dart';

class MyPostsPage extends StatefulWidget {
  final Function()? onPostChanged;

  const MyPostsPage({super.key, this.onPostChanged});

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  String _userId = '', _userType = '';
  List<ForumPost> _userPosts = [];

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

  Future<void> _loadUserData() async {
    try {
      final userData = await UserService.getUserData();
      setState(() {
        _userId = userData['userId'] ?? '';
        _userType = userData['userType'] ?? '';
      });

      _fetchUserPosts();
      print('Loaded user data - ID: $_userId, Type: $_userType');
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _fetchUserPosts() async {
    try {
      final posts = await ForumBackend().getUserPosts(_userId);
      print('Fetched user posts: ${posts.length} posts');
      for (var post in posts) {
        print(
          'Post ${post.id}: ${post.content} - Mood: ${post.mood.displayName}',
        );
      }
      setState(() {
        _userPosts = posts;
      });
    } catch (e) {
      print('Error fetching user posts: $e');
    }
  }

  Future<void> _editPost(ForumPost post) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => EditPostDialog(post: post),
    );

    if (result != null) {
      try {
        final response = await ForumBackend().updatePost(
          postId: post.id,
          content: result['content'],
          mood: result['mood'],
          userId: _userId,
        );

        if (response['success']) {
          _fetchUserPosts(); // Refresh the posts
          widget.onPostChanged?.call(); // Notify parent to refresh
          _showSnackBar('Post updated successfully!');
        } else {
          _showSnackBar('Failed to update post: ${response['message']}');
        }
      } catch (e) {
        _showSnackBar('Error updating post: $e');
      }
    }
  }

  Future<void> _deletePost(ForumPost post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await ForumBackend().deletePost(postId: post.id);

        if (response['success']) {
          _fetchUserPosts(); // Refresh the posts
          widget.onPostChanged?.call(); // Notify parent to refresh
          _showSnackBar('Post deleted successfully!');
        } else {
          _showSnackBar('Failed to delete post: ${response['message']}');
        }
      } catch (e) {
        _showSnackBar('Error deleting post: $e');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF667EEA),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'My Posts',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        backgroundColor: const Color(0xFFD1A1E3),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _userPosts.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _userPosts.length,
                itemBuilder: (context, index) {
                  return MyPostCard(
                    post: _userPosts[index],
                    onEdit: (post) => _editPost(post),
                    onDelete: (post) => _deletePost(post),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFD1A1E3).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.article_outlined,
              size: 60,
              color: Color(0xFFD1A1E3),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No posts yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Share your thoughts and feelings\nwith the community',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF718096),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class MyPostCard extends StatelessWidget {
  final ForumPost post;
  final Function(ForumPost) onEdit;
  final Function(ForumPost) onDelete;

  const MyPostCard({
    super.key,
    required this.post,
    required this.onEdit,
    required this.onDelete,
  });

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
                  _formatTimestamp(post.timestamp),
                  style: const TextStyle(
                    color: Color(0xFF718096),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Color(0xFF718096)),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit(post);
                    } else if (value == 'delete') {
                      onDelete(post);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18, color: Color(0xFF667EEA)),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              post.content,
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: post.isLiked
                        ? const Color(0xFFE53E3E).withOpacity(0.1)
                        : const Color(0xFFF7FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: post.isLiked
                          ? const Color(0xFFE53E3E).withOpacity(0.3)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite,
                        color: post.isLiked
                            ? const Color(0xFFE53E3E)
                            : const Color(0xFF718096),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${post.likes}',
                        style: TextStyle(
                          color: post.isLiked
                              ? const Color(0xFFE53E3E)
                              : const Color(0xFF718096),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                if (post.isSaved)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3182CE).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF3182CE).withOpacity(0.3),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bookmark,
                          color: Color(0xFF3182CE),
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Saved',
                          style: TextStyle(
                            color: Color(0xFF3182CE),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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
        color: post.mood.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: post.mood.color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(post.mood.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            post.mood.displayName,
            style: TextStyle(
              color: post.mood.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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

class EditPostDialog extends StatefulWidget {
  final ForumPost post;

  const EditPostDialog({super.key, required this.post});

  @override
  State<EditPostDialog> createState() => _EditPostDialogState();
}

class _EditPostDialogState extends State<EditPostDialog> {
  late TextEditingController _contentController;
  late MoodType _selectedMood;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.post.content);
    _selectedMood = widget.post.mood;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Post'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Content',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                hintText: 'Share your thoughts...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF667EEA)),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 4,
              minLines: 3,
            ),
            const SizedBox(height: 20),
            const Text(
              'How are you feeling?',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MoodType.values.map((mood) {
                final isSelected = _selectedMood == mood;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMood = mood;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? mood.color.withOpacity(0.2)
                          : const Color(0xFFF7FAFC),
                      borderRadius: BorderRadius.circular(20),
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
                        Text(mood.emoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_contentController.text.trim().isNotEmpty) {
              Navigator.of(context).pop({
                'content': _contentController.text.trim(),
                'mood': _selectedMood.displayName,
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667EEA),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Update'),
        ),
      ],
    );
  }
}
