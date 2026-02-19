import 'package:hive/hive.dart';

part 'sub_task_model.g.dart';

@HiveType(typeId: 1)
class SubTaskModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final bool isCompleted;

  SubTaskModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  factory SubTaskModel.fromMap(Map<String, dynamic> map) {
    return SubTaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      isCompleted: map['isCompleted'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  SubTaskModel copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return SubTaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
