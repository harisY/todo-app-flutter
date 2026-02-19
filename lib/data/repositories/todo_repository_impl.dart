import 'dart:async';

import '../../core/error/exception.dart';
import '../../core/error/failure.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../data_sources/todo_local_data_source.dart';
import '../models/sub_task_model.dart';
import '../models/todo_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoLocalDataSource localDataSource;

  TodoRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Todo>> getAllTodos() async {
    try {
      final todoModels = await localDataSource.getAllTodos();
      return todoModels.map(_toEntity).toList();
    } on CacheException {
      throw CacheFailure('Failed to retrieve todos from local storage');
    }
  }

  @override
  Future<List<Todo>> getTodosByFilter(String filter) async {
    final todos = await getAllTodos();
    switch (filter) {
      case 'active':
        return todos.where((todo) => !todo.isCompleted).toList();
      case 'completed':
        return todos.where((todo) => todo.isCompleted).toList();
      case 'overdue':
        return todos.where((todo) => todo.isOverdue).toList();
      default:
        return todos;
    }
  }

  @override
  Future<Todo?> getTodoById(String id) async {
    try {
      final todoModel = await localDataSource.getTodoById(id);
      if (todoModel == null) return null;
      return _toEntity(todoModel);
    } on CacheException {
      throw CacheFailure('Failed to retrieve todo');
    }
  }

  @override
  Future<void> addTodo(Todo todo) async {
    try {
      final todoModel = _fromEntity(todo);
      await localDataSource.addTodo(todoModel);
    } on CacheException {
      throw CacheFailure('Failed to add todo');
    }
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    try {
      final todoModel = _fromEntity(todo);
      await localDataSource.updateTodo(todoModel);
    } on CacheException {
      throw CacheFailure('Failed to update todo');
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    try {
      await localDataSource.deleteTodo(id);
    } on CacheException {
      throw CacheFailure('Failed to delete todo');
    }
  }

  @override
  Future<void> deleteAllCompleted() async {
    try {
      await localDataSource.deleteAllCompleted();
    } on CacheException {
      throw CacheFailure('Failed to delete completed todos');
    }
  }

  @override
  Stream<List<Todo>> watchTodos() async* {
    // For now, just emit all todos
    // In a real app, you could use Hive's watch feature
    yield await getAllTodos();
  }

  // Mappers
  Todo _toEntity(TodoModel model) {
    return Todo(
      id: model.id,
      title: model.title,
      description: model.description,
      isCompleted: model.isCompleted,
      createdAt: DateTime.fromMillisecondsSinceEpoch(model.createdAtMillis),
      priority: Priority.values[model.priorityIndex],
      category: Category(
        id: model.category['id'] as String,
        name: model.category['name'] as String,
        color: model.category['color'] as String,
        isDefault: model.category['isDefault'] as bool? ?? false,
      ),
      dueDate: model.dueDateMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(model.dueDateMillis!)
          : null,
      subTasks: model.subTasks
          .map(
            (s) => SubTask(
              id: s.id,
              title: s.title,
              isCompleted: s.isCompleted,
            ),
          )
          .toList(),
    );
  }

  TodoModel _fromEntity(Todo entity) {
    return TodoModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      isCompleted: entity.isCompleted,
      createdAtMillis: entity.createdAt.millisecondsSinceEpoch,
      priorityIndex: entity.priority.index,
      category: {
        'id': entity.category.id,
        'name': entity.category.name,
        'color': entity.category.color,
      },
      dueDateMillis: entity.dueDate?.millisecondsSinceEpoch,
      subTasks: entity.subTasks
          .map(
            (s) => SubTaskModel(
              id: s.id,
              title: s.title,
              isCompleted: s.isCompleted,
            ),
          )
          .toList(),
    );
  }
}
