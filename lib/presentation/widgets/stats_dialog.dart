import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/todo/todo_notifier.dart';

class StatsDialog extends StatelessWidget {
  const StatsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoNotifier>(
      builder: (context, todoNotifier, child) {
        final todos = todoNotifier.todos;
        final total = todos.length;
        final completed = todoNotifier.completedCount;
        final active = todoNotifier.activeCount;
        final overdue = todoNotifier.overdueCount;
        final completionRate = total == 0 ? 0.0 : completed / total;

        return AlertDialog(
          title: const Text('Statistics'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatRow('Total Todos', total.toString()),
              _buildStatRow('Active', active.toString()),
              _buildStatRow('Completed', completed.toString()),
              _buildStatRow('Overdue', overdue.toString()),
              const SizedBox(height: 16),
              if (todos.isNotEmpty)
                Column(
                  children: [
                    const Text('Completion Rate', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 20,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: completionRate,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('${(completionRate * 100).toStringAsFixed(1)}%'),
                  ],
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            if (completed > 0)
              TextButton(
                onPressed: () {
                  todoNotifier.deleteAllCompleted();
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Clear Completed'),
              ),
          ],
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
