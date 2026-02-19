import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/hive_service.dart';
import '../../data/data_sources/category_local_data_source.dart';
import '../../data/data_sources/todo_local_data_source.dart';
import '../../data/models/category_model.dart';
import '../../data/models/todo_model.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/repositories/todo_repository_impl.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/todo_repository.dart';
import '../../domain/usecases/todos/todo_usecases.dart';
import '../../presentation/providers/category/category_notifier.dart';
import '../../presentation/providers/theme/theme_notifier.dart';
import '../../presentation/providers/todo/todo_notifier.dart';

class ServiceLocator {
  // Data Sources
  static late final TodoLocalDataSource todoLocalDataSource;
  static late final CategoryLocalDataSource categoryLocalDataSource;

  // Repositories
  static late final TodoRepository todoRepository;
  static late final CategoryRepository categoryRepository;

  // Use Cases
  static late final GetAllTodos getAllTodos;
  static late final GetTodoById getTodoById;
  static late final AddTodo addTodo;
  static late final UpdateTodo updateTodo;
  static late final DeleteTodo deleteTodo;
  static late final DeleteAllCompleted deleteAllCompleted;

  // Providers
  static late final TodoNotifier todoNotifier;
  static late final ThemeNotifier themeNotifier;
  static late final CategoryNotifier categoryNotifier;

  static Future<void> init() async {
    // Initialize Hive
    await HiveService.init();

    // Initialize Data Sources
    todoLocalDataSource = TodoLocalDataSourceImpl(
      todosBox: Hive.box<TodoModel>(AppConstants.todosBox),
    );
    categoryLocalDataSource = CategoryLocalDataSourceImpl(
      categoriesBox: Hive.box<CategoryModel>(AppConstants.categoriesBox),
    );

    // Initialize Repositories
    todoRepository = TodoRepositoryImpl(localDataSource: todoLocalDataSource);
    categoryRepository = CategoryRepositoryImpl(localDataSource: categoryLocalDataSource);

    // Initialize Use Cases
    getAllTodos = GetAllTodos(todoRepository);
    getTodoById = GetTodoById(todoRepository);
    addTodo = AddTodo(todoRepository);
    updateTodo = UpdateTodo(todoRepository);
    deleteTodo = DeleteTodo(todoRepository);
    deleteAllCompleted = DeleteAllCompleted(todoRepository);

    // Initialize Providers
    todoNotifier = TodoNotifier(repository: todoRepository);
    themeNotifier = ThemeNotifier();
    categoryNotifier = CategoryNotifier(repository: categoryRepository);

    // Load initial data
    await todoNotifier.loadTodos();
    await categoryNotifier.loadCategories();
  }
}
