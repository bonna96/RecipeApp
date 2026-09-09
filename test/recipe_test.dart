import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/models/ingredient_model.dart';
import 'package:recipe_app/models/recipe_model.dart';
import 'package:recipe_app/models/category_model.dart';
import 'package:recipe_app/utils/responsive.dart';

void main() {
  group('Recipe App Core Unit Tests', () {
    test('Dynamic Ingredient Scaling calculates mathematically accurate portions', () {
      const paneer = Ingredient(name: 'Paneer', amount: 400, unit: 'g');

      // Base serving: 2 portions. Scaled to 4 portions.
      final scaledAmount = paneer.getScaledAmount(originalServings: 2, targetServings: 4);
      expect(scaledAmount, 800.0);

      // Scaled to 1 portion
      final singleServing = paneer.getScaledAmount(originalServings: 2, targetServings: 1);
      expect(singleServing, 200.0);

      // Formatted output
      final formatted = paneer.getFormattedAmount(originalServings: 2, targetServings: 4);
      expect(formatted, '800 g');
    });

    test('Recipe model serialization and deserialization matches Firestore structure', () {
      final recipe = Recipe(
        id: 'rec_test_1',
        title: 'Butter Chicken',
        category: 'Curry',
        imageUrl: 'https://example.com/butter_chicken.jpg',
        prepTimeMinutes: 30,
        calories: 550,
        rating: 4.9,
        reviewCount: 20,
        baseServings: 2,
        ingredients: const [
          Ingredient(name: 'Chicken Breast', amount: 500, unit: 'g'),
          Ingredient(name: 'Butter', amount: 50, unit: 'g'),
        ],
        instructions: const ['Marinate chicken', 'Cook in spiced butter gravy'],
        isFavorite: true,
      );

      final map = recipe.toMap();
      final reconstructed = Recipe.fromMap(map, recipe.id);

      expect(reconstructed.id, 'rec_test_1');
      expect(reconstructed.title, 'Butter Chicken');
      expect(reconstructed.ingredients.length, 2);
      expect(reconstructed.ingredients.first.amount, 500.0);
      expect(reconstructed.isFavorite, isTrue);
    });

    test('CategoryModel correctly maps attributes', () {
      const category = CategoryModel(id: 'cat_italian', name: 'Italian', icon: '🍕');
      final map = category.toMap();
      final reconstructed = CategoryModel.fromMap(map, 'cat_italian');

      expect(reconstructed.name, 'Italian');
      expect(reconstructed.icon, '🍕');
    });

    test('Responsive breakpoints constants are properly defined', () {
      expect(Responsive.mobileMaxWidth, 768.0);
      expect(Responsive.tabletMaxWidth, 1100.0);
      expect(Responsive.desktopContentMaxWidth, 1300.0);
    });

    test('Recipe updates image and ingredients via copyWith', () {
      final initial = Recipe(
        id: 'rec_edit_test',
        title: 'Original Recipe',
        category: 'Breakfast',
        imageUrl: 'https://example.com/old.jpg',
        prepTimeMinutes: 15,
        calories: 300,
        baseServings: 2,
        ingredients: const [
          Ingredient(name: 'Eggs', amount: 2, unit: 'pcs'),
        ],
        instructions: const ['Whisk and fry'],
      );

      final updated = initial.copyWith(
        title: 'Updated Gourmet Omelette',
        imageUrl: 'https://example.com/new_gourmet.jpg',
        ingredients: const [
          Ingredient(name: 'Organic Eggs', amount: 3, unit: 'pcs'),
          Ingredient(name: 'Parmesan', amount: 30, unit: 'g'),
        ],
        prepTimeMinutes: 20,
      );

      expect(updated.title, 'Updated Gourmet Omelette');
      expect(updated.imageUrl, 'https://example.com/new_gourmet.jpg');
      expect(updated.ingredients.length, 2);
      expect(updated.ingredients.first.amount, 3.0);
      expect(updated.prepTimeMinutes, 20);
      // Original id and category are preserved
      expect(updated.id, 'rec_edit_test');
      expect(updated.category, 'Breakfast');
    });
  });
}
