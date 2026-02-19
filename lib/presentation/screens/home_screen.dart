import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/todo.dart';
import '../providers/theme/theme_notifier.dart';
import '../providers/todo/todo_notifier.dart';
import '../widgets/todo_card.dart';
import '../widgets/add_edit_todo_dialog.dart';
import '../widgets/stats_dialog.dart';
import '../widgets/empty_state.dart';
import 'manage_categories_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _subTaskController = TextEditingController();
  
  // Form controllers (initialized when needed)
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  
  Category _selectedCategory = Category.defaults.first;
  Priority _selectedPriority = Priority.medium;
  DateTime? _selectedDueDate;
  final List<SubTask> _subTasks = [];

  @override
  void dispose() {
    _subTaskController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _initControllers() {
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _subTaskController.clear();
    _subTasks.clear();
    _selectedCategory = Category.defaults.first;
    _selectedPriority = Priority.medium;
    _selectedDueDate = null;
  }

  void _addSubTask() {
    if (_subTaskController.text.trim().isEmpty) return;
    setState(() {
      _subTasks.add(SubTask(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _subTaskController.text.trim(),
      ));
      _subTaskController.clear();
    });
  }

  void _removeSubTask(String id) {
    setState(() {
      _subTasks.removeWhere((s) => s.id == id);
    });
  }

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      final timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (timePicked != null) {
        setState(() {
          _selectedDueDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            timePicked.hour,
            timePicked.minute,
          );
        });
      }
    }
  }

  void _showAddTodoDialog() {
    _initControllers();
    _resetForm();

    showDialog(
      context: context,
      builder: (context) => AddEditTodoDialog(
        titleController: _titleController,
        descriptionController: _descriptionController,
        selectedCategory: _selectedCategory,
        selectedPriority: _selectedPriority,
        selectedDueDate: _selectedDueDate,
        subTasks: _subTasks,
        subTaskController: _subTaskController,
        onAddSubTask: _addSubTask,
        onRemoveSubTask: _removeSubTask,
        onSelectDueDate: _selectDueDate,
        onCategoryChanged: (cat) => setState(() => _selectedCategory = cat),
        onPriorityChanged: (pri) => setState(() => _selectedPriority = pri),
        onSave: () {
          if (_titleController.text.trim().isEmpty) return;

          final todo = Todo(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            createdAt: DateTime.now(),
            priority: _selectedPriority,
            category: _selectedCategory,
            dueDate: _selectedDueDate,
            subTasks: List.from(_subTasks),
          );

          context.read<TodoNotifier>().addTodo(todo);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEditTodoDialog(Todo todo) {
    _initControllers();
    _titleController.text = todo.title;
    _descriptionController.text = todo.description;
    _selectedCategory = todo.category;
    _selectedPriority = todo.priority;
    _selectedDueDate = todo.dueDate;
    _subTasks.clear();
    _subTasks.addAll(todo.subTasks);

    showDialog(
      context: context,
      builder: (context) => AddEditTodoDialog(
        titleController: _titleController,
        descriptionController: _descriptionController,
        selectedCategory: _selectedCategory,
        selectedPriority: _selectedPriority,
        selectedDueDate: _selectedDueDate,
        subTasks: _subTasks,
        subTaskController: _subTaskController,
        onAddSubTask: _addSubTask,
        onRemoveSubTask: _removeSubTask,
        onSelectDueDate: _selectDueDate,
        onCategoryChanged: (cat) => setState(() => _selectedCategory = cat),
        onPriorityChanged: (pri) => setState(() => _selectedPriority = pri),
        onSave: () {
          if (_titleController.text.trim().isEmpty) return;

          final updatedTodo = todo.copyWith(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            category: _selectedCategory,
            priority: _selectedPriority,
            dueDate: _selectedDueDate,
            subTasks: List.from(_subTasks),
          );

          context.read<TodoNotifier>().updateTodo(updatedTodo);
          Navigator.pop(context);
        },
        isEditing: true,
      ),
    );
  }

  void _showStatsDialog() {
    showDialog(
      context: context,
      builder: (context) => StatsDialog(),
    );
  }

  void _navigateToManageCategories() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ManageCategoriesScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Consumer<ThemeNotifier>(
            builder: (context, themeNotifier, child) {
              return IconButton(
                icon: Icon(
                  themeNotifier.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () {
                  themeNotifier.toggleTheme();
                },
                tooltip: 'Toggle Theme',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.label),
            onPressed: _navigateToManageCategories,
            tooltip: 'Manage Categories',
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: _showStatsDialog,
            tooltip: 'Statistics',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              context.read<TodoNotifier>().setSortBy(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'date', child: Text('Sort by Date')),
              const PopupMenuItem(value: 'dueDate', child: Text('Sort by Due Date')),
              const PopupMenuItem(value: 'priority', child: Text('Sort by Priority')),
              const PopupMenuItem(value: 'alphabetical', child: Text('Sort Alphabetically')),
            ],
            icon: const Icon(Icons.sort),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              context.read<TodoNotifier>().setFilter(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All')),
              const PopupMenuItem(value: 'active', child: Text('Active')),
              const PopupMenuItem(value: 'completed', child: Text('Completed')),
              const PopupMenuItem(value: 'overdue', child: Text('Overdue')),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Consumer<TodoNotifier>(
        builder: (context, todoNotifier, child) {
          final todos = todoNotifier.filteredAndSortedTodos;
          final searchQuery = todoNotifier.searchQuery;
          final isLoading = todoNotifier.isLoading;
          final isAnyActionLoading = todoNotifier.isAnyActionLoading;

          return Stack(
            children: [
              Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search todos...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  todoNotifier.setSearchQuery('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                      onChanged: (val) => todoNotifier.setSearchQuery(val),
                    ),
                  ),
                  
                  // Stats Summary
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        _buildStatChip('All', todoNotifier.todos.length, Colors.blue),
                        const SizedBox(width: 8),
                        _buildStatChip('Active', todoNotifier.activeCount, Colors.orange),
                        const SizedBox(width: 8),
                        _buildStatChip('Done', todoNotifier.completedCount, Colors.green),
                      ],
                    ),
                  ),
                  
                  // Todo List
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : todos.isEmpty
                            ? const EmptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.all(8),
                                itemCount: todos.length,
                                itemBuilder: (context, index) {
                                  final todo = todos[index];
                                  return TodoCard(
                                    todo: todo,
                                    onToggle: () => todoNotifier.toggleTodo(todo),
                                    onEdit: () => _showEditTodoDialog(todo),
                                    onDelete: () {
                                      todoNotifier.deleteTodo(todo.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${todo.title} deleted'),
                                          action: SnackBarAction(
                                            label: 'Undo',
                                            onPressed: () {
                                              todoNotifier.undoDeleteTodo();
                                            },
                                          ),
                                          duration: const Duration(seconds: 4),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                  ),
                ],
              ),
              if (isAnyActionLoading && !isLoading)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            todoNotifier.isAdding
                                ? 'Adding...'
                                : todoNotifier.isUpdating
                                    ? 'Updating...'
                                    : todoNotifier.isDeleting
                                        ? 'Deleting...'
                                        : 'Loading...',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<TodoNotifier>(
        builder: (context, todoNotifier, child) {
          return FloatingActionButton(
            onPressed: todoNotifier.isAnyActionLoading ? null : _showAddTodoDialog,
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color,
        child: Text(
          '$count',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
      label: Text(label),
      padding: EdgeInsets.zero,
    );
  }
}
