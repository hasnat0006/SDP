import 'package:client/backend/main_query.dart';
import 'package:client/forum/forum_models.dart';
import 'package:flutter/cupertino.dart';

class ForumBackend {
  Future<Map<String, dynamic>> post({
    required String content,
    required String mood,
    required String userId,
  }) async {
    try {
      final response = await postToBackend('forum/post-content', {
        'id': userId,
        'content': content,
        'mood': mood,
      });

      return {
        'success': true,
        'message': 'Account created successfully!',
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Signup failed: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  Future<List<ForumPost>> getUserPosts(String userId) async {
    try {
      final response = await getFromBackend('forum/get-posts?id=$userId');

      print(response);
      return (response['data'] as List)
          .map((post) => ForumPost.fromJson(post))
          .toList();
    } catch (e) {
      print('Error fetching user posts: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> updatePost({
    required String postId,
    required String content,
    required String mood,
    required String userId,
  }) async {
    try {
      final response = await postToBackend('forum/update-post', {
        'postId': postId,
        'content': content,
        'mood': mood,
      });

      return {
        'success': true,
        'message': 'Post updated successfully!',
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Update failed: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> deletePost({required String postId}) async {
    try {
      final response = await postToBackend('forum/delete-post', {
        'postId': postId,
      });

      return {
        'success': true,
        'message': 'Post deleted successfully!',
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Delete failed: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  Future<List<ForumPost>> getAllPosts() async {
    try {
      final response = await getFromBackend('forum/get-all-posts');

      debugPrint('Response from getAllPosts: $response');

      final finalResponse = (response['data'] as List)
          .map((post) => ForumPost.fromJson(post))
          .toList();
      // print("Final res: $finalResponse");
      debugPrint('Length of finalResponse: ${finalResponse.length}');
      // debugPrint('All posts: $finalResponse');
      for (var post in finalResponse) {
        debugPrint(
          'Post ID: ${post.id}, Content: ${post.content}, Mood: ${post.mood}, Likes: ${post.likes}',
        );
      }
      return finalResponse;
    } catch (e) {
      print('Error fetching all posts: $e');
      return [];
    }
  }
}
