import '../models/workout.dart';

class WorkoutService {
  Future<List<Workout>> fetchWorkouts({int page = 1, int limit = 10}) async {
    await Future.delayed(const Duration(seconds: 1));

    if (page > 2) {
      return [];
    }

    return List.generate(limit, (index) {
      final idIndex = (page - 1) * limit + index;
      return Workout(
        id: 'workout_$idIndex',
        title: 'Workout $idIndex',
        description: 'Description for workout $idIndex',
        duration: 30 + (idIndex % 3) * 10,
        calories: 200 + (idIndex % 5) * 50,
        imageUrl: 'https://via.placeholder.com/150',
        difficulty: idIndex % 3 == 0 ? 'Advanced' : (idIndex % 2 == 0 ? 'Intermediate' : 'Beginner'),
      );
    });
  }
}
