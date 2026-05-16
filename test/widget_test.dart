import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitlife/models/workout.dart';
import 'package:fitlife/widgets/workout_tile.dart';

void main() {
  testWidgets('WorkoutTile displays workout information correctly', (WidgetTester tester) async {
    final mockWorkout = Workout(
      id: '1',
      title: 'Super Workout',
      description: 'A great workout',
      duration: 45,
      calories: 300,
      imageUrl: 'test_url',
      difficulty: 'Intermediate',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WorkoutTile(workout: mockWorkout),
        ),
      ),
    );

    // Verify if title, duration and calories are displayed
    expect(find.text('Super Workout'), findsOneWidget);
    expect(find.text('45 min'), findsOneWidget);
    expect(find.text('300 kcal'), findsOneWidget);
  });
}
