import 'package:flutter_test/flutter_test.dart';
import 'package:fitlife/models/workout.dart';
import 'package:fitlife/services/validators.dart';

void main() {
  group('Workout Model Tests', () {
    final Map<String, dynamic> mockJson = {
      'id': '1',
      'title': 'Yoga',
      'description': 'Relaxing yoga session',
      'duration': 30,
      'calories': 150,
      'imageUrl': 'url',
      'difficulty': 'Beginner',
    };

    test('fromJson creates a valid Workout object', () {
      final workout = Workout.fromJson(mockJson);

      expect(workout.id, '1');
      expect(workout.title, 'Yoga');
      expect(workout.description, 'Relaxing yoga session');
      expect(workout.duration, 30);
      expect(workout.calories, 150);
      expect(workout.imageUrl, 'url');
      expect(workout.difficulty, 'Beginner');
    });

    test('toJson returns a valid map', () {
      final workout = Workout(
        id: '1',
        title: 'Yoga',
        description: 'Relaxing yoga session',
        duration: 30,
        calories: 150,
        imageUrl: 'url',
        difficulty: 'Beginner',
      );

      final json = workout.toJson();

      expect(json, mockJson);
    });
  });

  group('Validator Tests', () {
    test('validateSearchInput returns error for empty string', () {
      expect(validateSearchInput(''), 'Search field cannot be empty');
      expect(validateSearchInput(null), 'Search field cannot be empty');
    });

    test('validateSearchInput returns error for short string', () {
      expect(validateSearchInput('ab'), 'Enter at least 3 characters');
    });

    test('validateSearchInput returns null for valid string', () {
      expect(validateSearchInput('abc'), isNull);
      expect(validateSearchInput('valid search'), isNull);
    });
  });
}
