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

class SubTask {
  final String id;
  final String title;
  bool isCompleted;

  SubTask({
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
}

class Category {
  final String id;
  final String name;
  final String color;

  Category({
    required this.id,
    required this.name,
    required this.color,
  });

  static List<Category> defaults = [
    Category(id: 'personal', name: 'Personal', color: '2196F3'),
    Category(id: 'work', name: 'Work', color: '9C27B0'),
    Category(id: 'shopping', name: 'Shopping', color: '4CAF50'),
    Category(id: 'health', name: 'Health', color: 'F44336'),
    Category(id: 'other', name: 'Other', color: '607D8B'),
  ];
}

class Todo {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final Priority priority;
  final Category category;
  final DateTime? dueDate;
  final List<SubTask> subTasks;

  Todo({
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
}
