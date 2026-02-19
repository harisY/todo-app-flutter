import '../../../core/usecases/usecase.dart';
import '../../entities/todo.dart';
import '../../repositories/todo_repository.dart';

class GetAllTodos implements UseCase<List<Todo>, NoParams> {
  final TodoRepository repository;

  GetAllTodos(this.repository);

  @override
  Future<List<Todo>> call(NoParams params) async {
    return await repository.getAllTodos();
  }
}

class GetTodoById implements UseCase<Todo?, String> {
  final TodoRepository repository;

  GetTodoById(this.repository);

  @override
  Future<Todo?> call(String params) async {
    return await repository.getTodoById(params);
  }
}

class AddTodo implements UseCase<void, Todo> {
  final TodoRepository repository;

  AddTodo(this.repository);

  @override
  Future<void> call(Todo params) async {
    await repository.addTodo(params);
  }
}

class UpdateTodo implements UseCase<void, Todo> {
  final TodoRepository repository;

  UpdateTodo(this.repository);

  @override
  Future<void> call(Todo params) async {
    await repository.updateTodo(params);
  }
}

class DeleteTodo implements UseCase<void, String> {
  final TodoRepository repository;

  DeleteTodo(this.repository);

  @override
  Future<void> call(String params) async {
    await repository.deleteTodo(params);
  }
}

class DeleteAllCompleted implements UseCase<void, NoParams> {
  final TodoRepository repository;

  DeleteAllCompleted(this.repository);

  @override
  Future<void> call(NoParams params) async {
    await repository.deleteAllCompleted();
  }
}
