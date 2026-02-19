import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/todo.dart';
import '../providers/todo/todo_notifier.dart';

class TodoCard extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TodoCard({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = Color(int.parse(todo.priority.colorCode, radix: 16) + 0xFF000000);
    final categoryColor = Color(int.parse(todo.category.color, radix: 16) + 0xFF000000);

    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Todo'),
              content: Text('Are you sure you want to delete "${todo.title}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Delete', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          onToggle();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(todo.isCompleted ? 'Marked as active' : 'Marked as completed'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        // Delete is handled by the parent with undo functionality
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            ListTile(
              leading: Checkbox(
                value: todo.isCompleted,
                onChanged: (_) => onToggle(),
                activeColor: Colors.green,
              ),
              title: Text(
                todo.title,
                style: TextStyle(
                  decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                  color: todo.isCompleted ? Colors.grey : null,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (todo.description.isNotEmpty)
                    Text(
                      todo.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: categoryColor.withAlpha(51),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          todo.category.name,
                          style: TextStyle(color: categoryColor, fontSize: 10),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: priorityColor.withAlpha(51),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: priorityColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              todo.priority.label,
                              style: TextStyle(color: priorityColor, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      if (todo.dueDate != null) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: todo.isOverdue
                                ? Colors.red.withAlpha(51)
                                : Colors.grey.withAlpha(51),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 10,
                                color: todo.isOverdue ? Colors.red : Colors.grey,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${todo.dueDate!.day}/${todo.dueDate!.month}',
                                style: TextStyle(
                                  color: todo.isOverdue ? Colors.red : Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (todo.subTasks.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: todo.progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                        minHeight: 4,
                      ),
                    ),
                    Text(
                      '${todo.completedSubTasksCount}/${todo.totalSubTasksCount} sub-tasks',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: onEdit,
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ),
            if (todo.subTasks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  children: todo.subTasks.map((subTask) => CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    value: subTask.isCompleted,
                    onChanged: (_) {
                      // Toggle subtask
                      final updatedSubTasks = todo.subTasks.map((s) {
                        if (s.id == subTask.id) {
                          return s.copyWith(isCompleted: !s.isCompleted);
                        }
                        return s;
                      }).toList();
                      final updatedTodo = todo.copyWith(subTasks: updatedSubTasks);
                      context.read<TodoNotifier>().updateTodo(updatedTodo);
                    },
                    title: Text(
                      subTask.title,
                      style: TextStyle(
                        fontSize: 12,
                        decoration: subTask.isCompleted ? TextDecoration.lineThrough : null,
                        color: subTask.isCompleted ? Colors.grey : null,
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  )).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
