import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import '../models/recipe_model.dart';
import 'dummy_data.dart';

/// FirebaseService manages database interactions with Cloud Firestore.
/// It features an intelligent Dual-Mode architecture:
/// 1. Connected Mode: Uses live Firestore collections ('recipes', 'categories') when Firebase is initialized.
/// 2. Offline / Demo Mode: Seamlessly provides an in-memory reactive data store when running
///    without Firebase configuration, enabling immediate testing and portfolio demonstration.
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal() {
    _initOfflineStore();
  }

  // In-memory reactive state for offline/demo fallback
  late List<Recipe> _offlineRecipes;
  late List<CategoryModel> _offlineCategories;
  final _recipeStreamController = StreamController<List<Recipe>>.broadcast();
  final _categoryStreamController = StreamController<List<CategoryModel>>.broadcast();

  void _initOfflineStore() {
    _offlineRecipes = List.from(DummyData.initialRecipes);
    _offlineCategories = List.from(DummyData.initialCategories);
  }

  bool get isFirebaseConnected {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  FirebaseFirestore? get _firestore {
    if (isFirebaseConnected) {
      return FirebaseFirestore.instance;
    }
    return null;
  }

  // ================= RECIPES =================

  /// Real-time stream of recipes from Firestore or local store
  Stream<List<Recipe>> getRecipesStream() {
    final firestore = _firestore;
    if (firestore != null) {
      return firestore.collection('recipes').snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return Recipe.fromMap(doc.data(), doc.id);
        }).toList();
      });
    }

    // Emit current offline recipes immediately, then listen to updates
    Future.microtask(() => _recipeStreamController.add(List.unmodifiable(_offlineRecipes)));
    return _recipeStreamController.stream;
  }

  /// Fetch recipes once
  Future<List<Recipe>> fetchRecipes() async {
    final firestore = _firestore;
    if (firestore != null) {
      try {
        final querySnapshot = await firestore.collection('recipes').get();
        if (querySnapshot.docs.isNotEmpty) {
          return querySnapshot.docs
              .map((doc) => Recipe.fromMap(doc.data(), doc.id))
              .toList();
        }
      } catch (e) {
        debugPrint('Firestore fetch error (falling back to offline store): $e');
      }
    }
    return List.unmodifiable(_offlineRecipes);
  }

  /// Add a new recipe to Firestore or local store
  Future<void> addRecipe(Recipe recipe) async {
    final firestore = _firestore;
    if (firestore != null) {
      try {
        await firestore.collection('recipes').doc(recipe.id).set(recipe.toMap());
        return;
      } catch (e) {
        debugPrint('Firestore add error: $e');
      }
    }

    // Offline / Demo fallback
    _offlineRecipes.insert(0, recipe);
    _recipeStreamController.add(List.unmodifiable(_offlineRecipes));
  }

  /// Toggle favorite status of a recipe
  Future<void> toggleFavorite(String recipeId, bool currentStatus) async {
    final newStatus = !currentStatus;
    final firestore = _firestore;
    if (firestore != null) {
      try {
        await firestore.collection('recipes').doc(recipeId).update({
          'isFavorite': newStatus,
        });
        return;
      } catch (e) {
        debugPrint('Firestore favorite toggle error: $e');
      }
    }

    // Offline / Demo fallback
    final index = _offlineRecipes.indexWhere((r) => r.id == recipeId);
    if (index != -1) {
      _offlineRecipes[index] = _offlineRecipes[index].copyWith(isFavorite: newStatus);
      _recipeStreamController.add(List.unmodifiable(_offlineRecipes));
    }
  }

  /// Update an existing recipe in Firestore or local store
  Future<void> updateRecipe(Recipe updatedRecipe) async {
    final firestore = _firestore;
    if (firestore != null) {
      try {
        await firestore
            .collection('recipes')
            .doc(updatedRecipe.id)
            .update(updatedRecipe.toMap());
        return;
      } catch (e) {
        debugPrint('Firestore update error: $e');
      }
    }

    // Offline / Demo fallback
    final index = _offlineRecipes.indexWhere((r) => r.id == updatedRecipe.id);
    if (index != -1) {
      _offlineRecipes[index] = updatedRecipe;
      _recipeStreamController.add(List.unmodifiable(_offlineRecipes));
    }
  }

  /// Delete a recipe from Firestore or local store
  Future<void> deleteRecipe(String recipeId) async {
    final firestore = _firestore;
    if (firestore != null) {
      try {
        await firestore.collection('recipes').doc(recipeId).delete();
        return;
      } catch (e) {
        debugPrint('Firestore delete error: $e');
      }
    }

    // Offline / Demo fallback
    _offlineRecipes.removeWhere((r) => r.id == recipeId);
    _recipeStreamController.add(List.unmodifiable(_offlineRecipes));
  }

  // ================= CATEGORIES =================

  /// Real-time stream of categories
  Stream<List<CategoryModel>> getCategoriesStream() {
    final firestore = _firestore;
    if (firestore != null) {
      return firestore.collection('categories').snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return CategoryModel.fromMap(doc.data(), doc.id);
        }).toList();
      });
    }

    Future.microtask(() => _categoryStreamController.add(List.unmodifiable(_offlineCategories)));
    return _categoryStreamController.stream;
  }

  /// Fetch categories list
  Future<List<CategoryModel>> fetchCategories() async {
    final firestore = _firestore;
    if (firestore != null) {
      try {
        final querySnapshot = await firestore.collection('categories').get();
        if (querySnapshot.docs.isNotEmpty) {
          return querySnapshot.docs
              .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
              .toList();
        }
      } catch (e) {
        debugPrint('Firestore category fetch error: $e');
      }
    }
    return List.unmodifiable(_offlineCategories);
  }

  /// Add new category in real-time
  Future<void> addCategory(CategoryModel category) async {
    final firestore = _firestore;
    if (firestore != null) {
      try {
        await firestore.collection('categories').doc(category.id).set(category.toMap());
        return;
      } catch (e) {
        debugPrint('Firestore add category error: $e');
      }
    }

    // Offline / Demo fallback
    _offlineCategories.add(category);
    _categoryStreamController.add(List.unmodifiable(_offlineCategories));
  }
}
