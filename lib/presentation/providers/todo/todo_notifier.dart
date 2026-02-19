import 'package:flutter/foundation.dart';

import '../../../domain/entities/todo.dart';
import '../../../domain/repositories/todo_repository.dart';
import 'todo_state.dart';

class TodoNotifier extends ChangeNotifier {
  final TodoRepository repository;

  TodoNotifier({required this.repository});

  TodoState _state = const TodoInitial();
  TodoState get state => _state;

  Todo? _lastDeletedTodo;
  String? _lastDeletedTodoId;

  bool _isAdding = false;
  bool _isUpdating = false;
  bool _isDeleting = false;
  bool _isLoading = false;

  bool get isAdding => _isAdding;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;
  bool get isLoading => _isLoading;
  bool get isAnyActionLoading => _isAdding || _isUpdating || _isDeleting || _isLoading;

  List<Todo> get todos {
    if (_state is TodoLoaded) {
      return (_state as TodoLoaded).todos;
    }
    return [];
  }

  String get filter {
    if (_state is TodoLoaded) {
      return (_state as TodoLoaded).filter;
    }
    return 'all';
  }

  String get sortBy {
    if (_state is TodoLoaded) {
      return (_state as TodoLoaded).sortBy;
    }
    return 'date';
  }

  String get searchQuery {
    if (_state is TodoLoaded) {
      return (_state as TodoLoaded).searchQuery;
    }
    return '';
  }

  List<Todo> get filteredAndSortedTodos {
    if (_state is TodoLoaded) {
      return (_state as TodoLoaded).filteredAndSortedTodos;
    }
    return [];
  }

  int get activeCount {
    if (_state is TodoLoaded) {
      return (_state as TodoLoaded).activeCount;
    }
    return 0;
  }

  int get completedCount {
    if (_state is TodoLoaded) {
      return (_state as TodoLoaded).completedCount;
    }
    return 0;
  }

  int get overdueCount {
    if (_state is TodoLoaded) {
      return (_state as TodoLoaded).overdueCount;
    }
    return 0;
  }

  bool get hasDeletedTodo => _lastDeletedTodo != null || _lastDeletedTodoId != null;

  Future<void> loadTodos() async {
    _isLoading = true;
    _state = const TodoLoading();
    notifyListeners();

    try {
      final todoList = await repository.getAllTodos();
      _state = TodoLoaded(todos: todoList);
    } catch (e) {
      _state = TodoError('Failed to load todos: $e');
    } finally {
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> addTodo(Todo todo) async {
    _isAdding = true;
    notifyListeners();

    try {
      await repository.addTodo(todo);
      await loadTodos();
    } catch (e) {
      _state = TodoError('Failed to add todo: $e');
      notifyListeners();
    } finally {
      _isAdding = false;
      notifyListeners();
    }
  }

  Future<void> updateTodo(Todo todo) async {
    _isUpdating = true;
    notifyListeners();

    try {
      await repository.updateTodo(todo);
      await loadTodos();
    } catch (e) {
      _state = TodoError('Failed to update todo: $e');
      notifyListeners();
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  Future<void> toggleTodo(Todo todo) async {
    await updateTodo(todo.copyWith(isCompleted: !todo.isCompleted));
  }

  Future<void> deleteTodo(String id) async {
    _isDeleting = true;
    notifyListeners();

    try {
      final todoToDelete = todos.firstWhere((t) => t.id == id, orElse: () => throw Exception('Todo not found'));
      _lastDeletedTodo = todoToDelete;
      _lastDeletedTodoId = id;
      await repository.deleteTodo(id);
      await loadTodos();
    } catch (e) {
      _state = TodoError('Failed to delete todo: $e');
      notifyListeners();
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  Future<void> undoDeleteTodo() async {
    if (_lastDeletedTodo != null) {
      try {
        await repository.addTodo(_lastDeletedTodo!);
        _lastDeletedTodo = null;
        _lastDeletedTodoId = null;
        await loadTodos();
      } catch (e) {
        _state = TodoError('Failed to undo delete: $e');
        notifyListeners();
      }
    } else if (_lastDeletedTodoId != null) {
      // If we only have the ID, we can't fully restore, so just clear the state
      _lastDeletedTodoId = null;
    }
  }

  void clearDeletedTodo() {
    _lastDeletedTodo = null;
    _lastDeletedTodoId = null;
  }

  Future<void> deleteAllCompleted() async {
    try {
      await repository.deleteAllCompleted();
      await loadTodos();
    } catch (e) {
      _state = TodoError('Failed to delete completed todos: $e');
      notifyListeners();
    }
  }

  void setFilter(String filter) {
    if (_state is TodoLoaded) {
      _state = (_state as TodoLoaded).copyWith(filter: filter);
      notifyListeners();
    }
  }

  void setSortBy(String sortBy) {
    if (_state is TodoLoaded) {
      _state = (_state as TodoLoaded).copyWith(sortBy: sortBy);
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    if (_state is TodoLoaded) {
      _state = (_state as TodoLoaded).copyWith(searchQuery: query);
      notifyListeners();
    }
  }
}
