# Forum Feature - MindOra

A comprehensive anonymous forum feature for mood tracking and emotional expression.

## 📱 Features

### Core Functionality
- **Anonymous Posting**: Users can share thoughts without revealing identity
- **Mood-Based Posts**: Each post is tagged with a specific mood type
- **Interactive Elements**: Like and save functionality for posts
- **Post Filtering**: Filter posts by mood type
- **Saved Posts**: Dedicated page to view bookmarked posts
- **Real-time Updates**: Pull-to-refresh functionality

### UI/UX Features
- **Smooth Animations**: Fade-in effects and button animations
- **Mood-Based Colors**: Visual mood indicators with emojis and colors
- **Clean Design**: Minimal, emotionally expressive interface
- **Responsive Layout**: Optimized for different screen sizes

## 🎨 Mood Types

The forum supports 10 different mood types:

| Mood | Emoji | Color |
|------|-------|-------|
| Happy | 😊 | Green |
| Sad | 😢 | Blue |
| Angry | 😠 | Red |
| Calm | 😌 | Teal |
| Excited | 🎉 | Orange |
| Anxious | 😰 | Purple |
| Grateful | 🙏 | Yellow |
| Lonely | 😔 | Gray |
| Content | 😄 | Light Green |
| Frustrated | 😤 | Light Red |

## 📁 File Structure

```
lib/forum/
├── forum.dart              # Main forum page with post list
├── forum_models.dart       # Data models (ForumPost, MoodType)
├── create_post.dart        # Post creation interface
├── saved_posts.dart        # Saved posts viewing page
└── example_integration.dart # Example navigation integration
```

## 🚀 Integration

### Method 1: Add to Bottom Navigation

Replace your existing navbar with the example integration:

```dart
import 'package:client/forum/example_integration.dart';

// In your main.dart or routing
home: const CustomBottomNavBarWithForum(),
```

### Method 2: Direct Navigation

Navigate directly to the forum page:

```dart
import 'package:client/forum/forum.dart';

// Navigate to forum
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const ForumPage()),
);
```

## 🔧 Customization

### Adding New Mood Types

In `forum_models.dart`, add new moods to the `MoodType` enum:

```dart
enum MoodType {
  // ... existing moods
  optimistic('Optimistic', '✨', Color(0xFF9F7AEA)),
  overwhelmed('Overwhelmed', '😵', Color(0xFF718096)),
}
```

### Styling Changes

Main colors used throughout the forum:

- **Primary**: `Color(0xFF667EEA)` (Purple-blue)
- **Background**: `Color(0xFFF8F9FA)` (Light gray)
- **Card Background**: `Colors.white`
- **Text Primary**: `Color(0xFF2D3748)` (Dark gray)
- **Text Secondary**: `Color(0xFF718096)` (Medium gray)

### Animation Customization

Modify animation durations in the respective files:

```dart
// In forum.dart
_fadeController = AnimationController(
  duration: const Duration(milliseconds: 800), // Adjust duration
  vsync: this,
);
```

## 📊 Mock Data

The forum comes with 6 sample posts showcasing different moods and interaction states. Mock data is generated in the `_loadMockData()` method in `forum.dart`.

## 🔮 Future Enhancements

Potential features to add:

1. **Comments System**: Allow users to comment on posts
2. **Categories**: Add topic-based categorization
3. **Search Functionality**: Search through posts by content
4. **Report System**: Allow users to report inappropriate content
5. **Trending Posts**: Show popular posts based on likes
6. **Daily Challenges**: Mood-based writing prompts
7. **Analytics**: Personal mood tracking through posts
8. **Offline Support**: Local storage for saved posts

## 🎯 Usage Tips

1. **Testing**: Use the pull-to-refresh gesture to reload mock data
2. **Navigation**: Use the bookmark icon in the app bar to access saved posts
3. **Creating Posts**: Tap the floating action button to create new posts
4. **Filtering**: Tap mood chips at the top to filter posts by mood
5. **Interactions**: Tap like/save buttons to interact with posts

## 🐛 Troubleshooting

### Common Issues

1. **Import Errors**: Ensure all forum files are in the `lib/forum/` directory
2. **Animation Issues**: Make sure your StatefulWidget implements `TickerProviderStateMixin`
3. **Navigation Issues**: Check that you're importing the correct forum page

### Dependencies

The forum feature uses these packages (already in your pubspec.yaml):
- `flutter/material.dart`
- `intl` for date formatting

No additional dependencies required!

## 💡 Best Practices

1. **State Management**: Consider using Provider or Riverpod for larger apps
2. **Data Persistence**: Implement local storage (SharedPreferences/SQLite) or backend integration
3. **Performance**: Use `ListView.builder` for large lists (already implemented)
4. **Accessibility**: Add semantic labels for screen readers
5. **Error Handling**: Add try-catch blocks for production use

Enjoy building meaningful connections through mood-based sharing! 🌟
