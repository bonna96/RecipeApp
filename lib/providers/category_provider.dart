import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import '../services/firebase_service.dart';

class CategoryProvider with ChangeNotifier {
  final FirebaseService _service = FirebaseService();
  StreamSubscription<List<CategoryModel>>? _subscription;

  List<CategoryModel> _categories = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;

  CategoryProvider() {
    _initCategories();
  }

  List<CategoryModel> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  void _initCategories() {
    _subscription = _service.getCategoriesStream().listen((cats) {
      _categories = cats;
      _isLoading = false;
      notifyListeners();
    }, onError: (err) {
      debugPrint('Category stream error: $err');
      _isLoading = false;
      notifyListeners();
    });
  }

  void selectCategory(String categoryName) {
    if (_selectedCategory != categoryName) {
      _selectedCategory = categoryName;
      notifyListeners();
    }
  }

  Future<void> addCategory(String name, String icon) async {
    final newCat = CategoryModel(
      id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      icon: icon.trim().isEmpty ? '🍽️' : icon.trim(),
    );
    await _service.addCategory(newCat);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
