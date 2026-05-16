import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/workout.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workout = ModalRoute.of(context)!.settings.arguments as Workout;

    return Scaffold(
      appBar: AppBar(
        title: Text(workout.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CachedNetworkImage(
              imageUrl: workout.imageUrl,
              height: 250,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 250,
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 250,
                color: Colors.grey[300],
                child: const Icon(Icons.fitness_center, size: 100, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.title,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Chip(
                        label: Text(workout.difficulty),
                        backgroundColor: _getDifficultyColor(workout.difficulty),
                      ),
                      const Spacer(),
                      const Icon(Icons.timer, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${workout.duration} min'),
                      const SizedBox(width: 16),
                      const Icon(Icons.local_fire_department, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text('${workout.calories} kcal'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Workout Description',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    workout.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Workout started!')),
                        );
                      },
                      child: const Text(
                        'Start Workout',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green[200]!;
      case 'intermediate':
        return Colors.orange[200]!;
      case 'advanced':
        return Colors.red[200]!;
      default:
        return Colors.grey[200]!;
    }
  }
}
