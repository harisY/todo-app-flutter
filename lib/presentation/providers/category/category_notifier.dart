import 'package:flutter/foundation.dart';

import '../../../domain/entities/category.dart' as app_domain;
import '../../../domain/repositories/category_repository.dart';

class CategoryNotifier extends ChangeNotifier {
  final CategoryRepository repository;

  CategoryNotifier({required this.repository});

  List<app_domain.Category> _categories = app_domain.Category.defaults;
  bool _isLoading = false;
  String? _error;

  List<app_domain.Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await repository.getAllCategories();
      _error = null;
    } catch (e) {
      _error = 'Failed to load categories: $e';
      _categories = app_domain.Category.defaults;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(String name, String color) async {
    _isLoading = true;
    notifyListeners();

    try {
      final category = app_domain.Category(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        color: color,
        isDefault: false,
      );
      await repository.addCategory(category);
      await loadCategories();
    } catch (e) {
      _error = 'Failed to add category: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCategory(app_domain.Category category) async {
    _isLoading = true;
    notifyListeners();

    try {
      await repository.updateCategory(category);
      await loadCategories();
    } catch (e) {
      _error = 'Failed to update category: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await repository.deleteCategory(id);
      await loadCategories();
    } catch (e) {
      _error = 'Failed to delete category: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetToDefaults() async {
    _isLoading = true;
    notifyListeners();

    try {
      await repository.resetToDefaults();
      await loadCategories();
    } catch (e) {
      _error = 'Failed to reset categories: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
