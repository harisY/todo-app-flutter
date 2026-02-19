import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/todo.dart';
import '../providers/category/category_notifier.dart';

class AddEditTodoDialog extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final Category selectedCategory;
  final Priority selectedPriority;
  final DateTime? selectedDueDate;
  final List<SubTask> subTasks;
  final TextEditingController subTaskController;
  final VoidCallback onAddSubTask;
  final Function(String) onRemoveSubTask;
  final VoidCallback onSelectDueDate;
  final Function(Category) onCategoryChanged;
  final Function(Priority) onPriorityChanged;
  final VoidCallback onSave;
  final bool isEditing;

  const AddEditTodoDialog({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.selectedCategory,
    required this.selectedPriority,
    required this.selectedDueDate,
    required this.subTasks,
    required this.subTaskController,
    required this.onAddSubTask,
    required this.onRemoveSubTask,
    required this.onSelectDueDate,
    required this.onCategoryChanged,
    required this.onPriorityChanged,
    required this.onSave,
    this.isEditing = false,
  });

  @override
  State<AddEditTodoDialog> createState() => _AddEditTodoDialogState();
}

class _AddEditTodoDialogState extends State<AddEditTodoDialog> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryNotifier>(
      builder: (context, categoryNotifier, child) {
        // Use all categories from notifier
        final allCategories = categoryNotifier.categories;

        return AlertDialog(
          title: Text(widget.isEditing ? 'Edit Todo' : 'Add New Todo'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: widget.titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(),
                    hintText: 'Enter todo title',
                  ),
                  autofocus: !widget.isEditing,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: widget.descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    hintText: 'Enter description (optional)',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Category Selector - use ID as value to avoid equality issues
                DropdownButtonFormField<String>(
                  value: widget.selectedCategory.id,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: allCategories.map((cat) => DropdownMenuItem(
                    value: cat.id,
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Color(int.parse(cat.color, radix: 16) + 0xFF000000),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(cat.name),
                      ],
                    ),
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      final category = allCategories.firstWhere((c) => c.id == val);
                      widget.onCategoryChanged(category);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Priority Selector
                DropdownButtonFormField<Priority>(
                  initialValue: widget.selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: Priority.values.map((priority) => DropdownMenuItem(
                    value: priority,
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Color(int.parse(priority.colorCode, radix: 16) + 0xFF000000),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(priority.label),
                      ],
                    ),
                  )).toList(),
                  onChanged: (val) => widget.onPriorityChanged(val!),
                ),
                const SizedBox(height: 16),

                // Due Date
                InkWell(
                  onTap: widget.onSelectDueDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Due Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      widget.selectedDueDate != null
                          ? '${widget.selectedDueDate!.day}/${widget.selectedDueDate!.month}/${widget.selectedDueDate!.year} ${widget.selectedDueDate!.hour}:${widget.selectedDueDate!.minute.toString().padLeft(2, '0')}'
                          : 'Select due date',
                      style: TextStyle(
                        color: widget.selectedDueDate != null
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // SubTasks
                const Text('Sub-tasks', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.subTaskController,
                        decoration: const InputDecoration(
                          hintText: 'Add sub-task',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onSubmitted: (_) => widget.onAddSubTask(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: widget.onAddSubTask,
                      icon: const Icon(Icons.add_circle),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...widget.subTasks.map((subTask) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    subTask.isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                    size: 20,
                    color: subTask.isCompleted ? Colors.green : null,
                  ),
                  title: Text(
                    subTask.title,
                    style: TextStyle(
                      decoration: subTask.isCompleted ? TextDecoration.lineThrough : null,
                      color: subTask.isCompleted ? Colors.grey : null,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!widget.isEditing)
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => widget.onRemoveSubTask(subTask.id),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: widget.onSave,
              child: Text(widget.isEditing ? 'Save' : 'Add'),
            ),
          ],
        );
      },
    );
  }
}
