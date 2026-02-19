import 'package:hive/hive.dart';

import 'sub_task_model.dart';

part 'todo_model.g.dart';

@HiveType(typeId: 2)
class TodoModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final bool isCompleted;

  @HiveField(4)
  final int createdAtMillis;

  @HiveField(5)
  final int priorityIndex;

  @HiveField(6)
  final Map<String, dynamic> category;

  @HiveField(7)
  final int? dueDateMillis;

  @HiveField(8)
  final List<SubTaskModel> subTasks;

  TodoModel({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.createdAtMillis,
    this.priorityIndex = 1,
    required this.category,
    this.dueDateMillis,
    this.subTasks = const [],
  });

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      isCompleted: map['isCompleted'] as bool,
      createdAtMillis: map['createdAtMillis'] as int,
      priorityIndex: map['priorityIndex'] as int? ?? 1,
      category: map['category'] as Map<String, dynamic>,
      dueDateMillis: map['dueDateMillis'] as int?,
      subTasks: (map['subTasks'] as List<dynamic>?)
              ?.map((e) => SubTaskModel.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAtMillis': createdAtMillis,
      'priorityIndex': priorityIndex,
      'category': category,
      'dueDateMillis': dueDateMillis,
      'subTasks': subTasks.map((s) => s.toMap()).toList(),
    };
  }

  TodoModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    int? createdAtMillis,
    int? priorityIndex,
    Map<String, dynamic>? category,
    int? dueDateMillis,
    List<SubTaskModel>? subTasks,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAtMillis: createdAtMillis ?? this.createdAtMillis,
      priorityIndex: priorityIndex ?? this.priorityIndex,
      category: category ?? this.category,
      dueDateMillis: dueDateMillis ?? this.dueDateMillis,
      subTasks: subTasks ?? this.subTasks,
    );
  }
}
