class Workout {
  final String id;
  final String title;
  final String description;
  final int duration;
  final int calories;
  final String imageUrl;
  final String difficulty;

  Workout({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.calories,
    required this.imageUrl,
    required this.difficulty,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      duration: json['duration'] as int,
      calories: json['calories'] as int,
      imageUrl: json['imageUrl'] as String,
      difficulty: json['difficulty'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'duration': duration,
      'calories': calories,
      'imageUrl': imageUrl,
      'difficulty': difficulty,
    };
  }
}
