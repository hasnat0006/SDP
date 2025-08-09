import 'package:flutter/material.dart';

enum MoodType {
  happy('Happy', '😊', Color(0xFF48BB78)),
  sad('Sad', '😢', Color(0xFF4299E1)),
  angry('Angry', '😠', Color(0xFFE53E3E)),
  calm('Calm', '😌', Color(0xFF38B2AC)),
  excited('Excited', '🎉', Color(0xFFED8936)),
  anxious('Anxious', '😰', Color(0xFF9F7AEA)),
  grateful('Grateful', '🙏', Color(0xFFD69E2E)),
  lonely('Lonely', '😔', Color(0xFF718096)),
  content('Content', '😄', Color(0xFF68D391)),
  frustrated('Frustrated', '😤', Color(0xFFFC8181));

  const MoodType(this.displayName, this.emoji, this.color);

  final String displayName;
  final String emoji;
  final Color color;
}

class ForumPost {
  final String id;
  final String content;
  final MoodType mood;
  final DateTime timestamp;
  int likes;
  bool isLiked;
  bool isSaved;

  ForumPost({
    required this.id,
    required this.content,
    required this.mood,
    required this.timestamp,
    this.likes = 0,
    this.isLiked = false,
    this.isSaved = false,
  });

  ForumPost copyWith({
    String? id,
    String? content,
    MoodType? mood,
    DateTime? timestamp,
    int? likes,
    bool? isLiked,
    bool? isSaved,
  }) {
    return ForumPost(
      id: id ?? this.id,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'mood': mood.name,
      'timestamp': timestamp.toIso8601String(),
      'likes': likes,
      'isLiked': isLiked,
      'isSaved': isSaved,
    };
  }

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    return ForumPost(
      id: json['id'],
      content: json['content'],
      mood: MoodType.values.firstWhere(
        (m) => m.name == json['mood'],
        orElse: () => MoodType.content,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      likes: json['likes'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      isSaved: json['isSaved'] ?? false,
    );
  }
}
