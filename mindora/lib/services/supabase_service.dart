import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'dart:typed_data';

class SupabaseService {
  static bool _initialized = false;

  static SupabaseClient get client {
    if (!_initialized) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return Supabase.instance.client;
  }

  static bool get isInitialized => _initialized;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

      // print('🔍 Supabase URL: ${supabaseUrl?.substring(0, 20)}...');
      // print('🔍 Supabase Key: ${supabaseAnonKey?.substring(0, 20)}...');

      if (supabaseUrl == null || supabaseAnonKey == null) {
        // print('⚠️ Supabase credentials not found in .env file. Image upload will be disabled.',);
        return;
      }

      // Check if credentials are placeholder values
      if (supabaseUrl.contains('your_supabase') ||
          supabaseAnonKey.contains('your_supabase')) {
        // print('⚠️ Supabase credentials are placeholder values. Please update .env file with real credentials.',);
        return;
      }

      // print('🚀 Initializing Supabase...');
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: false, // Disable debug to avoid namespace issues
      );

      _initialized = true;
      // print('✅ Supabase initialized successfully');

      // Test storage access
      try {
        final buckets = await client.storage.listBuckets();
        // print('📁 Available buckets: ${buckets.map((b) => b.name).toList()}');

        final hasProfileImagesBucket = buckets.any(
          (b) => b.name == 'profile-images',
        );
        if (hasProfileImagesBucket) {
          // print('✅ profile-images bucket found');
        } else {
          // print(  '❌ profile-images bucket NOT found. Please create it in Supabase Dashboard.',          );
        }
      } catch (storageError) {
        // print('⚠️ Storage access test failed: $storageError');
      }
    } catch (e) {
      // print('❌ Failed to initialize Supabase: $e');
      // print('📝 Image upload will be disabled. Please check your Supabase credentials.');
      // Don't throw error to prevent app crash
    }
  }

  /// Upload profile image to Supabase storage
  /// Returns the public URL of the uploaded image
  static Future<String> uploadProfileImage(
    String userId,
    File imageFile,
  ) async {
    if (!_initialized) {
      throw Exception('Supabase not initialized. Image upload is disabled.');
    }

    try {
      // print('🔄 Starting image upload for user: $userId');
      
      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'profile_$userId\_$timestamp.jpg';
      final filePath = 'profile-images/$fileName';
      
      // print('📁 Upload path: $filePath');

      // Read file as bytes
      final bytes = await imageFile.readAsBytes();
      // print('📋 File size: ${bytes.length} bytes');

      // Check if bucket exists first
      try {
        final buckets = await client.storage.listBuckets();
        final hasProfileImagesBucket = buckets.any(
          (b) => b.name == 'profile-images',
        );
        if (!hasProfileImagesBucket) {
          throw Exception('profile-images bucket does not exist. Please create it in Supabase Dashboard.');
        }
      } catch (e) {
        // print('⚠️ Error checking buckets: $e');
        // Continue anyway in case it's a permissions issue
      }

      // Upload to Supabase storage
      // Upload to Supabase storage
      // print('📤 Uploading to Supabase storage...');
      await client.storage
          .from('profile-images')
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // Get public URL
      final publicUrl = client.storage
          .from('profile-images')
          .getPublicUrl(filePath);

      // print('✅ Image uploaded successfully to: $publicUrl');
      return publicUrl;
    } catch (e) {
      // print('❌ Error uploading image: $e');
      // Print more detailed error information
      if (e.toString().contains('duplicate')) {
        // print('💡 File might already exist, trying with upsert...');
        // Already using upsert, so this shouldn't happen
      }
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Upload profile image from bytes to Supabase storage (for web)
  /// Returns the public URL of the uploaded image
  static Future<String> uploadProfileImageFromBytes(
    String userId,
    Uint8List imageBytes,
  ) async {
    if (!_initialized) {
      throw Exception('Supabase not initialized. Image upload is disabled.');
    }

    try {
      // print('🔄 Starting image upload from bytes for user: $userId');
      
      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'profile_$userId\_$timestamp.jpg';
      final filePath = 'profile-images/$fileName';
      
      // print('📁 Upload path: $filePath');
      // print('📋 Image size: ${imageBytes.length} bytes');

      // Check if bucket exists first
      try {
        final buckets = await client.storage.listBuckets();
        final hasProfileImagesBucket = buckets.any(
          (b) => b.name == 'profile-images',
        );
        if (!hasProfileImagesBucket) {
          throw Exception('profile-images bucket does not exist. Please create it in Supabase Dashboard.');
        }
      } catch (e) {
        // print('⚠️ Error checking buckets: $e');
        // Continue anyway in case it's a permissions issue
      }

      // Upload to Supabase storage
      // print('📤 Uploading to Supabase storage...');
      await client.storage
          .from('profile-images')
          .uploadBinary(
            filePath,
            imageBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // Get public URL
      final publicUrl = client.storage
          .from('profile-images')
          .getPublicUrl(filePath);

      // print('✅ Image uploaded successfully to: $publicUrl');
      return publicUrl;
    } catch (e) {
      // print('❌ Error uploading image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Delete profile image from Supabase storage
  static Future<void> deleteProfileImage(String imageUrl) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      // Find the index of 'profile-images' in the path
      final bucketIndex = pathSegments.indexOf('profile-images');
      if (bucketIndex == -1 || bucketIndex >= pathSegments.length - 1) {
        throw Exception('Invalid image URL format');
      }

      // Get the file path after 'profile-images'
      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      await client.storage.from('profile-images').remove([filePath]);

      // print('✅ Image deleted successfully');
    } catch (e) {
      // print('❌ Error deleting image: $e');
      // Don't throw error for deletion failures to avoid blocking profile updates
    }
  }

  /// Update profile image: delete old one and upload new one
  static Future<String> updateProfileImage(
    String userId,
    File newImageFile,
    String? oldImageUrl,
  ) async {
    try {
      // Delete old image if it exists
      if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
        await deleteProfileImage(oldImageUrl);
      }

      // Upload new image
      final newImageUrl = await uploadProfileImage(userId, newImageFile);
      return newImageUrl;
    } catch (e) {
      // print('❌ Error updating profile image: $e');
      throw Exception('Failed to update profile image: $e');
    }
  }

  /// Update profile image from bytes: delete old one and upload new one (for web)
  static Future<String> updateProfileImageFromBytes(
    String userId,
    Uint8List imageBytes,
    String? oldImageUrl,
  ) async {
    try {
      // Delete old image if it exists
      if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
        await deleteProfileImage(oldImageUrl);
      }

      // Upload new image
      final newImageUrl = await uploadProfileImageFromBytes(userId, imageBytes);
      return newImageUrl;
    } catch (e) {
      // print('❌ Error updating profile image: $e');
      throw Exception('Failed to update profile image: $e');
    }
  }
}
