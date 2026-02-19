import '../entities/todo.dart';

abstract class TodoRepository {
  Future<List<Todo>> getAllTodos();
  Future<List<Todo>> getTodosByFilter(String filter);
  Future<Todo?> getTodoById(String id);
  Future<void> addTodo(Todo todo);
  Future<void> updateTodo(Todo todo);
  Future<void> deleteTodo(String id);
  Future<void> deleteAllCompleted();
  Stream<List<Todo>> watchTodos();
}
