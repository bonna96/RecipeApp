import 'ingredient_model.dart';

class Recipe {
  final String id;
  final String title;
  final String category;
  final String imageUrl;
  final int prepTimeMinutes;
  final int calories;
  final double rating;
  final int reviewCount;
  final int baseServings;
  final List<Ingredient> ingredients;
  final List<String> instructions;
  final bool isFavorite;
  final DateTime? createdAt;

  const Recipe({
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.prepTimeMinutes,
    required this.calories,
    this.rating = 4.5,
    this.reviewCount = 12,
    this.baseServings = 2,
    required this.ingredients,
    required this.instructions,
    this.isFavorite = false,
    this.createdAt,
  });

  Recipe copyWith({
    String? id,
    String? title,
    String? category,
    String? imageUrl,
    int? prepTimeMinutes,
    int? calories,
    double? rating,
    int? reviewCount,
    int? baseServings,
    List<Ingredient>? ingredients,
    List<String>? instructions,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      calories: calories ?? this.calories,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      baseServings: baseServings ?? this.baseServings,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'imageUrl': imageUrl,
      'prepTimeMinutes': prepTimeMinutes,
      'calories': calories,
      'rating': rating,
      'reviewCount': reviewCount,
      'baseServings': baseServings,
      'ingredients': ingredients.map((i) => i.toMap()).toList(),
      'instructions': instructions,
      'isFavorite': isFavorite,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map, [String? docId]) {
    final rawIngredients = map['ingredients'] as List<dynamic>? ?? [];
    final parsedIngredients = rawIngredients.map((item) {
      if (item is Map<String, dynamic>) {
        return Ingredient.fromMap(item);
      } else if (item is Map) {
        return Ingredient.fromMap(Map<String, dynamic>.from(item));
      }
      return const Ingredient(name: '', amount: 0, unit: '');
    }).toList();

    final rawInstructions = map['instructions'] as List<dynamic>? ?? [];
    final parsedInstructions = rawInstructions.map((e) => e.toString()).toList();

    DateTime? parsedDate;
    if (map['createdAt'] != null) {
      if (map['createdAt'] is String) {
        parsedDate = DateTime.tryParse(map['createdAt'] as String);
      }
    }

    return Recipe(
      id: docId ?? map['id'] as String? ?? '',
      title: map['title'] as String? ?? 'Untitled Recipe',
      category: map['category'] as String? ?? 'Main Course',
      imageUrl: map['imageUrl'] as String? ?? '',
      prepTimeMinutes: (map['prepTimeMinutes'] is num)
          ? (map['prepTimeMinutes'] as num).toInt()
          : 20,
      calories: (map['calories'] is num)
          ? (map['calories'] as num).toInt()
          : 350,
      rating: (map['rating'] is num)
          ? (map['rating'] as num).toDouble()
          : 4.5,
      reviewCount: (map['reviewCount'] is num)
          ? (map['reviewCount'] as num).toInt()
          : 10,
      baseServings: (map['baseServings'] is num)
          ? (map['baseServings'] as num).toInt()
          : 2,
      ingredients: parsedIngredients,
      instructions: parsedInstructions,
      isFavorite: map['isFavorite'] as bool? ?? false,
      createdAt: parsedDate ?? DateTime.now(),
    );
  }
}
