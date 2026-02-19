import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/todo.dart';
import '../providers/category/category_notifier.dart';

class ManageCategoryDialog extends StatefulWidget {
  final Category? category;

  const ManageCategoryDialog({super.key, this.category});

  @override
  State<ManageCategoryDialog> createState() => _ManageCategoryDialogState();
}

class _ManageCategoryDialogState extends State<ManageCategoryDialog> {
  late TextEditingController _nameController;
  late String _selectedColor;
  bool _isEditing = false;

  // Predefined color options
  static const List<String> colorOptions = [
    '2196F3', // Blue
    '9C27B0', // Purple
    '4CAF50', // Green
    'F44336', // Red
    'FF9800', // Orange
    '00BCD4', // Cyan
    'E91E63', // Pink
    '3F51B5', // Indigo
    '009688', // Teal
    '795548', // Brown
    '607D8B', // Blue Grey
    '673AB7', // Deep Purple
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.category != null;
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _selectedColor = widget.category?.color ?? colorOptions.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Text(_isEditing ? 'Edit Category' : 'Add Category'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                hintText: 'e.g., Work, Personal, Shopping',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            const Text('Select Color:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: colorOptions.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(int.parse(color, radix: 16) + 0xFF000000),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? (isDarkMode ? Colors.white : Colors.black)
                            : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveCategory,
          child: Text(_isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  void _saveCategory() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }

    if (_isEditing && widget.category != null) {
      final updatedCategory = Category(
        id: widget.category!.id,
        name: name,
        color: _selectedColor,
        isDefault: widget.category!.isDefault,
      );
      context.read<CategoryNotifier>().updateCategory(updatedCategory);
    } else {
      context.read<CategoryNotifier>().addCategory(name, _selectedColor);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEditing ? 'Category updated' : 'Category added')),
    );
  }
}
