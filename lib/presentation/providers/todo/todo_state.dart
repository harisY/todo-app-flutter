import 'package:equatable/equatable.dart';

import '../../../domain/entities/todo.dart';

abstract class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object?> get props => [];
}

class TodoInitial extends TodoState {
  const TodoInitial();
}

class TodoLoading extends TodoState {
  const TodoLoading();
}

class TodoLoaded extends TodoState {
  final List<Todo> todos;
  final String filter;
  final String sortBy;
  final String searchQuery;

  const TodoLoaded({
    required this.todos,
    this.filter = 'all',
    this.sortBy = 'date',
    this.searchQuery = '',
  });

  List<Todo> get filteredAndSortedTodos {
    var result = todos;

    // Search filter
    if (searchQuery.isNotEmpty) {
      result = result.where((todo) =>
          todo.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          todo.description.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }

    // Status filter
    switch (filter) {
      case 'active':
        result = result.where((todo) => !todo.isCompleted).toList();
        break;
      case 'completed':
        result = result.where((todo) => todo.isCompleted).toList();
        break;
      case 'overdue':
        result = result.where((todo) => todo.isOverdue).toList();
        break;
    }

    // Sort
    result = List.from(result);
    switch (sortBy) {
      case 'date':
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'dueDate':
        result.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case 'priority':
        result.sort((a, b) => b.priority.index.compareTo(a.priority.index));
        break;
      case 'alphabetical':
        result.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    return result;
  }

  int get activeCount => todos.where((t) => !t.isCompleted).length;
  int get completedCount => todos.where((t) => t.isCompleted).length;
  int get overdueCount => todos.where((t) => t.isOverdue).length;

  @override
  List<Object?> get props => [todos, filter, sortBy, searchQuery];

  TodoLoaded copyWith({
    List<Todo>? todos,
    String? filter,
    String? sortBy,
    String? searchQuery,
  }) {
    return TodoLoaded(
      todos: todos ?? this.todos,
      filter: filter ?? this.filter,
      sortBy: sortBy ?? this.sortBy,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class TodoError extends TodoState {
  final String message;

  const TodoError(this.message);

  @override
  List<Object?> get props => [message];
}
