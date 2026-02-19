import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String color;
  final bool isDefault;

  const Category({
    required this.id,
    required this.name,
    required this.color,
    this.isDefault = false,
  });

  static List<Category> defaults = [
    const Category(id: 'personal', name: 'Personal', color: '2196F3', isDefault: true),
    const Category(id: 'work', name: 'Work', color: '9C27B0', isDefault: true),
    const Category(id: 'shopping', name: 'Shopping', color: '4CAF50', isDefault: true),
    const Category(id: 'health', name: 'Health', color: 'F44336', isDefault: true),
    const Category(id: 'other', name: 'Other', color: '607D8B', isDefault: true),
  ];

  @override
  List<Object?> get props => [id, name, color, isDefault];
}
