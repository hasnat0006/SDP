import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'forum_models.dart';
import 'saved_posts.dart';
import 'create_post.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  List<ForumPost> posts = [];
  List<ForumPost> savedPosts = [];
  String selectedMoodFilter = 'All';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _loadMockData();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _loadMockData() {
    setState(() {
      posts = [
        ForumPost(
          id: '1',
          content:
              'Feeling grateful today for the small moments that bring joy. Sometimes it\'s just about appreciating what we have.',
          mood: MoodType.happy,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          likes: 12,
          isLiked: false,
          isSaved: false,
        ),
        ForumPost(
          id: '2',
          content:
              'Having one of those days where everything feels overwhelming. Trying to take it one step at a time.',
          mood: MoodType.sad,
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          likes: 8,
          isLiked: true,
          isSaved: false,
        ),
        ForumPost(
          id: '3',
          content:
              'Just finished meditation and feeling so centered. The peace of mind is incredible.',
          mood: MoodType.calm,
          timestamp: DateTime.now().subtract(const Duration(hours: 8)),
          likes: 15,
          isLiked: false,
          isSaved: true,
        ),
        ForumPost(
          id: '4',
          content:
              'Traffic, deadlines, and everything going wrong today. Need to find my center again.',
          mood: MoodType.angry,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          likes: 6,
          isLiked: false,
          isSaved: false,
        ),
        ForumPost(
          id: '5',
          content:
              'Achieved a personal goal today! It took months of work but persistence pays off. 🎉',
          mood: MoodType.excited,
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
          likes: 23,
          isLiked: true,
          isSaved: true,
        ),
        ForumPost(
          id: '6',
          content:
              'Feeling uncertain about the path ahead. Sometimes not knowing is the hardest part.',
          mood: MoodType.anxious,
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          likes: 9,
          isLiked: false,
          isSaved: false,
        ),
      ];
    });
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

  void _toggleLike(String postId) {
    setState(() {
      final postIndex = posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        posts[postIndex].isLiked = !posts[postIndex].isLiked;
        posts[postIndex].likes += posts[postIndex].isLiked ? 1 : -1;
      }
    });
  }

  void _toggleSave(String postId) {
    setState(() {
      final postIndex = posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        posts[postIndex].isSaved = !posts[postIndex].isSaved;

        if (posts[postIndex].isSaved) {
          savedPosts.add(posts[postIndex]);
        } else {
          savedPosts.removeWhere((post) => post.id == postId);
        }
      }
    });
  }

  void _addNewPost(ForumPost newPost) {
    setState(() {
      posts.insert(0, newPost);
    });
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildMoodFilter(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await Future.delayed(const Duration(seconds: 1));
                  _loadMockData();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredPosts.length,
                  itemBuilder: (context, index) {
                    return PostCard(
                      post: filteredPosts[index],
                      onLike: _toggleLike,
                      onSave: _toggleSave,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreatePostPage(onPostCreated: _addNewPost),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Share'),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
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

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onSave,
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
        onTap: () {
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
              Icon(
                widget.post.isLiked ? Icons.favorite : Icons.favorite_border,
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
      onTap: () {
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
            Icon(
              widget.post.isSaved ? Icons.bookmark : Icons.bookmark_border,
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
