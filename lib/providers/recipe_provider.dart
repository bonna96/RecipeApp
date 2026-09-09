import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/recipe_model.dart';
import '../services/firebase_service.dart';

class RecipeProvider with ChangeNotifier {
  final FirebaseService _service = FirebaseService();
  StreamSubscription<List<Recipe>>? _subscription;

  List<Recipe> _recipes = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isLoading = true;

  // Active serving sizes keyed by recipe ID
  final Map<String, int> _servingsMap = {};

  RecipeProvider() {
    _initRecipes();
  }

  List<Recipe> get allRecipes => _recipes;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  void _initRecipes() {
    _subscription = _service.getRecipesStream().listen((items) {
      _recipes = items;
      _isLoading = false;
      notifyListeners();
    }, onError: (err) {
      debugPrint('Recipe stream error: $err');
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Get recipes filtered by active category and search query
  List<Recipe> getFilteredRecipes(String category) {
    _selectedCategory = category;
    return _recipes.where((recipe) {
      final matchesCategory = (category.toLowerCase() == 'all') ||
          (recipe.category.toLowerCase() == category.toLowerCase());

      final matchesSearch = _searchQuery.isEmpty ||
          recipe.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          recipe.ingredients.any(
            (i) => i.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          );

      return matchesCategory && matchesSearch;
    }).toList();
  }

  /// Get list of favorited recipes
  List<Recipe> get favoriteRecipes {
    return _recipes.where((r) => r.isFavorite).toList();
  }

  /// Set search query with live update
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Clear active search
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  /// Toggle favorite status of a recipe
  Future<void> toggleFavorite(String recipeId) async {
    final recipe = _recipes.firstWhere((r) => r.id == recipeId, orElse: () => _recipes.first);
    await _service.toggleFavorite(recipeId, recipe.isFavorite);
  }

  /// Add a new recipe
  Future<void> addRecipe(Recipe newRecipe) async {
    await _service.addRecipe(newRecipe);
  }

  /// Update an existing recipe
  Future<void> updateRecipe(Recipe updatedRecipe) async {
    await _service.updateRecipe(updatedRecipe);
    notifyListeners();
  }

  /// Delete a recipe
  Future<void> deleteRecipe(String recipeId) async {
    await _service.deleteRecipe(recipeId);
    notifyListeners();
  }

  /// Servings management: get current serving count for a recipe
  int getServings(Recipe recipe) {
    return _servingsMap[recipe.id] ?? recipe.baseServings;
  }

  /// Servings management: increment serving count
  void incrementServings(Recipe recipe) {
    final current = getServings(recipe);
    if (current < 20) {
      _servingsMap[recipe.id] = current + 1;
      notifyListeners();
    }
  }

  /// Servings management: decrement serving count
  void decrementServings(Recipe recipe) {
    final current = getServings(recipe);
    if (current > 1) {
      _servingsMap[recipe.id] = current - 1;
      notifyListeners();
    }
  }

  /// Reset servings to default base servings
  void resetServings(String recipeId) {
    _servingsMap.remove(recipeId);
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
