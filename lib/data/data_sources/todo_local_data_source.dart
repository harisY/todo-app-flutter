import 'package:hive/hive.dart';

import '../../core/error/exception.dart';
import '../models/todo_model.dart';

abstract class TodoLocalDataSource {
  Future<List<TodoModel>> getAllTodos();
  Future<TodoModel?> getTodoById(String id);
  Future<void> addTodo(TodoModel todo);
  Future<void> updateTodo(TodoModel todo);
  Future<void> deleteTodo(String id);
  Future<void> deleteAllCompleted();
  Future<void> clearAll();
}

class TodoLocalDataSourceImpl implements TodoLocalDataSource {
  final Box<TodoModel> todosBox;

  TodoLocalDataSourceImpl({required this.todosBox});

  @override
  Future<List<TodoModel>> getAllTodos() async {
    try {
      return todosBox.values.toList();
    } catch (e) {
      throw CacheException('Failed to get todos: $e');
    }
  }

  @override
  Future<TodoModel?> getTodoById(String id) async {
    try {
      return todosBox.get(id);
    } catch (e) {
      throw CacheException('Failed to get todo: $e');
    }
  }

  @override
  Future<void> addTodo(TodoModel todo) async {
    try {
      await todosBox.put(todo.id, todo);
    } catch (e) {
      throw CacheException('Failed to add todo: $e');
    }
  }

  @override
  Future<void> updateTodo(TodoModel todo) async {
    try {
      await todosBox.put(todo.id, todo);
    } catch (e) {
      throw CacheException('Failed to update todo: $e');
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    try {
      await todosBox.delete(id);
    } catch (e) {
      throw CacheException('Failed to delete todo: $e');
    }
  }

  @override
  Future<void> deleteAllCompleted() async {
    try {
      final completedTodos = todosBox.values.where((todo) => todo.isCompleted);
      for (final todo in completedTodos) {
        await todosBox.delete(todo.id);
      }
    } catch (e) {
      throw CacheException('Failed to delete completed todos: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await todosBox.clear();
    } catch (e) {
      throw CacheException('Failed to clear todos: $e');
    }
  }
}
