import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/main.dart';

void main() {
  testWidgets('Todo app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TodoApp());

    expect(find.text('Todo App'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
