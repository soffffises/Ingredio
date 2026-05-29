class Recipe {
  final String id;
  final String name;
  final String? thumbnail;
  List<String> ingredients;
  int matchCount;
  List<String> matchedIngredients;
  String? instructions;
  String? category;
  String? youtubeLink;
  List<String>? measures;

  Recipe({
    required this.id,
    required this.name,
    this.thumbnail,
    this.matchCount = 0,
    required this.ingredients,
    List<String>? matchedIngredients,
    this.instructions,
    this.category,
    this.youtubeLink,
    this.measures,
  }) : matchedIngredients = matchedIngredients ?? [];

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: _readString(json, ['id', 'idMeal']),
      name: _readString(json, ['name', 'strMeal']),
      thumbnail: _readNullableString(json, ['thumbnail', 'strMealThumb']),
      ingredients: _readStringList(json, ['ingredients']),
      matchCount: _readInt(json, ['matchCount']),
      matchedIngredients: _readStringList(json, ['matchedIngredients']),
      instructions:
          _readNullableString(json, ['instructions', 'strInstructions']),
      category: _readNullableString(json, ['category', 'strCategory']),
      youtubeLink: _readNullableString(json, ['youtubeLink', 'strYoutube']),
      measures: _readNullableStringList(json, ['measures']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'thumbnail': thumbnail,
      'ingredients': List<String>.from(ingredients),
      'matchCount': matchCount,
      'matchedIngredients': List<String>.from(matchedIngredients),
      'instructions': instructions,
      'category': category,
      'youtubeLink': youtubeLink,
      'measures': measures == null ? null : List<String>.from(measures!),
    };
  }
}

String _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value != null && value.toString().isNotEmpty) {
      return value.toString();
    }
  }
  return '';
}

String? _readNullableString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value != null && value.toString().isNotEmpty) {
      return value.toString();
    }
  }
  return null;
}

List<String> _readStringList(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
  }
  return const [];
}

List<String>? _readNullableStringList(
    Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
  }
  return null;
}

int _readInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    if (value is int) return value;
    final parsed = int.tryParse(value.toString());
    if (parsed != null) return parsed;
  }
  return 0;
}
