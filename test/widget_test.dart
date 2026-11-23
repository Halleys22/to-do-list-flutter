import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_list_flutter/main.dart';
import 'package:to_do_list_flutter/state/task_store.dart';
import 'package:to_do_list_flutter/models/task.dart';

void main() {
  test('Persistencia de fecha, categoría, estado y tema', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = TaskStore(prefs);
    await store.save(
      Task(
        id: '1',
        title: 'Entrega',
        category: 'Estudios',
        dueDate: DateTime(2026, 10, 20),
      ),
    );
    await store.toggle(store.tasks.single);
    await store.toggleTheme();
    final restored = TaskStore(prefs);
    expect(restored.tasks.single.dueDate, DateTime(2026, 10, 20));
    expect(restored.tasks.single.category, 'Estudios');
    expect(restored.progress, 1);
    expect(restored.dark, true);
    await restored.remove('1');
    expect(TaskStore(prefs).tasks, isEmpty);
  });
  testWidgets('Crear, validar, completar, editar y eliminar', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = TaskStore(await SharedPreferences.getInstance());
    await tester.pumpWidget(TodoApp(store: store));
    await tester.ensureVisible(find.text('Ver mis tareas'));
    await tester.tap(find.text('Ver mis tareas'));
    await tester.pumpAndSettle();
    expect(find.text('Un nuevo comienzo'), findsOneWidget);
    await tester.tap(find.text('Nueva tarea'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Guardar tarea'));
    await tester.tap(find.text('Guardar tarea'));
    await tester.pumpAndSettle();
    expect(find.text('Introduce un título para la tarea.'), findsOneWidget);
    await tester.enterText(
      find.byType(TextFormField).first,
      'Estudiar Flutter',
    );
    await tester.ensureVisible(find.text('Guardar tarea'));
    await tester.tap(find.text('Guardar tarea'));
    await tester.pumpAndSettle();
    expect(store.tasks.single.title, 'Estudiar Flutter');
    await tester.tap(find.text('Estudiar Flutter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Marcar como completada'));
    await tester.pumpAndSettle();
    expect(store.tasks.single.completed, true);
    await tester.tap(find.text('Editar tarea'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).first,
      'Entregar Flutter',
    );
    await tester.ensureVisible(find.text('Guardar tarea'));
    await tester.tap(find.text('Guardar tarea'));
    await tester.pumpAndSettle();
    expect(find.text('Entregar Flutter'), findsOneWidget);
    await tester.ensureVisible(find.text('Eliminar tarea'));
    await tester.tap(find.text('Eliminar tarea'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();
    expect(store.tasks, isEmpty);
  });
}
