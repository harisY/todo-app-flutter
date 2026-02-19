import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 0)
class CategoryModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String color;

  @HiveField(3)
  final bool isDefault;

  CategoryModel({
    required this.id,
    required this.name,
    required this.color,
    this.isDefault = false,
  });

  static List<CategoryModel> getDefaults() {
    return [
      CategoryModel(id: 'personal', name: 'Personal', color: '2196F3', isDefault: true),
      CategoryModel(id: 'work', name: 'Work', color: '9C27B0', isDefault: true),
      CategoryModel(id: 'shopping', name: 'Shopping', color: '4CAF50', isDefault: true),
      CategoryModel(id: 'health', name: 'Health', color: 'F44336', isDefault: true),
      CategoryModel(id: 'other', name: 'Other', color: '607D8B', isDefault: true),
    ];
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      color: map['color'] as String,
      isDefault: map['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'isDefault': isDefault,
    };
  }
}
