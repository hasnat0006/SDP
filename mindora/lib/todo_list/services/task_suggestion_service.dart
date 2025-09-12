import '../models/task_model.dart';
import '../backend.dart';

class TaskSuggestionService {
  static final TaskBackend _backend = TaskBackend();

  // Get AI-powered wellness-based task suggestions
  static Future<List<Task>> getWellnessBasedSuggestions(String userId) async {
    try {
      final suggestions = await _backend.getWellnessBasedSuggestions(userId);

      if (suggestions.isNotEmpty) {
        return suggestions;
      } else {
        // Fallback to dummy suggestions if API fails
        return getDummyTaskSuggestions().take(3).toList();
      }
    } catch (error) {
      print('Error getting wellness suggestions: $error');
      // Fallback to dummy suggestions
      return getDummyTaskSuggestions().take(3).toList();
    }
  }

  static List<Task> getDummyTaskSuggestions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      Task(
        id: 'suggestion_1',
        title: 'Drink 8 glasses of water',
        description: 'Stay hydrated throughout the day for better health',
        priority: TaskPriority.medium,
        dueDate: today.add(Duration(hours: 20)),
      ),
      Task(
        id: 'suggestion_2',
        title: 'Take a 15-minute walk',
        description: 'Fresh air and light exercise to boost your mood',
        priority: TaskPriority.low,
        dueDate: today.add(Duration(hours: 18)),
      ),
      Task(
        id: 'suggestion_3',
        title: 'Practice deep breathing for 5 minutes',
        description: 'Reduce stress and improve focus with breathing exercises',
        priority: TaskPriority.medium,
        dueDate: today.add(Duration(hours: 16)),
      ),
      Task(
        id: 'suggestion_4',
        title: 'Write in gratitude journal',
        description: 'Reflect on positive aspects of your day',
        priority: TaskPriority.low,
        dueDate: today.add(Duration(hours: 22)),
      ),
      Task(
        id: 'suggestion_5',
        title: 'Read for 20 minutes',
        description: 'Engage your mind with some good reading',
        priority: TaskPriority.low,
        dueDate: today.add(Duration(hours: 21)),
      ),
      Task(
        id: 'suggestion_6',
        title: 'Plan tomorrow\'s priorities',
        description: 'Set yourself up for success by planning ahead',
        priority: TaskPriority.medium,
        dueDate: today.add(Duration(hours: 19)),
      ),
      Task(
        id: 'suggestion_7',
        title: 'Connect with a friend or family member',
        description: 'Maintain social connections for mental wellbeing',
        priority: TaskPriority.medium,
        dueDate: today.add(Duration(hours: 17)),
      ),
      Task(
        id: 'suggestion_8',
        title: 'Do 10 minutes of stretching',
        description: 'Improve flexibility and reduce muscle tension',
        priority: TaskPriority.low,
        dueDate: today.add(Duration(hours: 15)),
      ),
    ];
  }

  // Get personalized suggestions based on user data (mock implementation)
  static List<Task> getPersonalizedSuggestions({
    String? userMood,
    String? lastActivity,
    int? stressLevel,
  }) {
    final allSuggestions = getDummyTaskSuggestions();

    // Simple logic to filter suggestions based on user data
    if (stressLevel != null && stressLevel > 7) {
      // High stress - suggest relaxation activities
      return allSuggestions
          .where(
            (task) =>
                task.title.toLowerCase().contains('breathing') ||
                task.title.toLowerCase().contains('walk') ||
                task.title.toLowerCase().contains('journal'),
          )
          .take(3)
          .toList();
    }

    if (userMood != null && userMood.toLowerCase().contains('sad')) {
      // Sad mood - suggest mood-boosting activities
      return allSuggestions
          .where(
            (task) =>
                task.title.toLowerCase().contains('connect') ||
                task.title.toLowerCase().contains('walk') ||
                task.title.toLowerCase().contains('read'),
          )
          .take(3)
          .toList();
    }

    // Default: return random 3-4 suggestions
    allSuggestions.shuffle();
    return allSuggestions.take(3).toList();
  }
}
