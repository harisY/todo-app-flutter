import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/category_model.dart';
import '../../data/models/sub_task_model.dart';
import '../../data/models/todo_model.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(CategoryModelAdapter());
    Hive.registerAdapter(SubTaskModelAdapter());
    Hive.registerAdapter(TodoModelAdapter());

    // Open boxes
    await Hive.openBox<TodoModel>(AppConstants.todosBox);
    await Hive.openBox(AppConstants.settingsBox);
    await Hive.openBox<CategoryModel>(AppConstants.categoriesBox);

    // Initialize default categories if empty
    final categoriesBox = Hive.box<CategoryModel>(AppConstants.categoriesBox);
    if (categoriesBox.isEmpty) {
      final defaults = CategoryModel.getDefaults();
      for (final category in defaults) {
        await categoriesBox.put(category.id, category);
      }
    }
  }

  static Box<TodoModel> get todosBox => Hive.box<TodoModel>(AppConstants.todosBox);
  static Box get settingsBox => Hive.box(AppConstants.settingsBox);
  static Box<CategoryModel> get categoriesBox => Hive.box<CategoryModel>(AppConstants.categoriesBox);
}
