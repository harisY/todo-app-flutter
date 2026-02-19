import 'package:hive/hive.dart';

import '../../core/error/exception.dart';
import '../models/category_model.dart';

abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>> getAllCategories();
  Future<void> addCategory(CategoryModel category);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
  Future<void> resetToDefaults();
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final Box<CategoryModel> categoriesBox;

  CategoryLocalDataSourceImpl({required this.categoriesBox});

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      return categoriesBox.values.toList();
    } catch (e) {
      throw CacheException('Failed to get categories: $e');
    }
  }

  @override
  Future<void> addCategory(CategoryModel category) async {
    try {
      await categoriesBox.put(category.id, category);
    } catch (e) {
      throw CacheException('Failed to add category: $e');
    }
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    try {
      await categoriesBox.put(category.id, category);
    } catch (e) {
      throw CacheException('Failed to update category: $e');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await categoriesBox.delete(id);
    } catch (e) {
      throw CacheException('Failed to delete category: $e');
    }
  }

  @override
  Future<void> resetToDefaults() async {
    try {
      await categoriesBox.clear();
      final defaults = CategoryModel.getDefaults();
      for (final category in defaults) {
        await categoriesBox.put(category.id, category);
      }
    } catch (e) {
      throw CacheException('Failed to reset categories: $e');
    }
  }
}
