import 'package:equatable/equatable.dart';

import 'category.dart';

export 'category.dart';

enum Priority { low, medium, high }

extension PriorityExtension on Priority {
  String get label {
    switch (this) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
    }
  }

  String get colorCode {
    switch (this) {
      case Priority.low:
        return '4CAF50';
      case Priority.medium:
        return 'FF9800';
      case Priority.high:
        return 'F44336';
    }
  }
}

class SubTask extends Equatable {
  final String id;
  final String title;
  final bool isCompleted;

  const SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  SubTask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [id, title, isCompleted];
}

class Todo extends Equatable {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final Priority priority;
  final Category category;
  final DateTime? dueDate;
  final List<SubTask> subTasks;

  const Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.createdAt,
    this.priority = Priority.medium,
    required this.category,
    this.dueDate,
    this.subTasks = const [],
  });

  int get completedSubTasksCount => subTasks.where((s) => s.isCompleted).length;
  int get totalSubTasksCount => subTasks.length;
  double get progress => totalSubTasksCount == 0 ? 0 : completedSubTasksCount / totalSubTasksCount;

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    Priority? priority,
    Category? category,
    DateTime? dueDate,
    List<SubTask>? subTasks,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      subTasks: subTasks ?? this.subTasks,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        isCompleted,
        createdAt,
        priority,
        category,
        dueDate,
        subTasks,
      ];
}
