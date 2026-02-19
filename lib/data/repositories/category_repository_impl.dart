import '../../core/error/exception.dart';
import '../../core/error/failure.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../data_sources/category_local_data_source.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource localDataSource;

  CategoryRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Category>> getAllCategories() async {
    try {
      final categoryModels = await localDataSource.getAllCategories();
      return categoryModels.map(_toEntity).toList();
    } on CacheException {
      throw CacheFailure('Failed to retrieve categories from local storage');
    }
  }

  @override
  Future<void> addCategory(Category category) async {
    try {
      final categoryModel = _fromEntity(category);
      await localDataSource.addCategory(categoryModel);
    } on CacheException {
      throw CacheFailure('Failed to add category');
    }
  }

  @override
  Future<void> updateCategory(Category category) async {
    try {
      final categoryModel = _fromEntity(category);
      await localDataSource.updateCategory(categoryModel);
    } on CacheException {
      throw CacheFailure('Failed to update category');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await localDataSource.deleteCategory(id);
    } on CacheException {
      throw CacheFailure('Failed to delete category');
    }
  }

  @override
  Future<void> resetToDefaults() async {
    try {
      await localDataSource.resetToDefaults();
    } on CacheException {
      throw CacheFailure('Failed to reset categories');
    }
  }

  Category _toEntity(CategoryModel model) {
    return Category(
      id: model.id,
      name: model.name,
      color: model.color,
      isDefault: model.isDefault,
    );
  }

  CategoryModel _fromEntity(Category entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      color: entity.color,
      isDefault: entity.isDefault,
    );
  }
}
