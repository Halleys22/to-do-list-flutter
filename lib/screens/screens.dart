import 'package:flutter/material.dart';

import '../models/task.dart';
import '../state/task_store.dart';
export 'welcome_screen.dart';
export 'task_list_screen.dart';
export 'task_form_screen.dart';
export 'task_detail_screen.dart';

const categories = ['Personal', 'Estudios', 'Trabajo'];
String dateLabel(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
// El ancho limitado permite utilizar la misma interfaz en móvil y escritorio.
Widget content(Widget child) => Align(
  alignment: Alignment.topCenter,
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 760),
    child: child,
  ),
);
Future<T?> open<T>(BuildContext context, Widget screen) =>
    Navigator.push<T>(context, MaterialPageRoute(builder: (_) => screen));
Future<void> deleteTask(
  BuildContext context,
  TaskStore store,
  Task task,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('¿Eliminar tarea?'),
      content: Text('Se eliminará «${task.title}».'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
  if (confirmed == true) await store.remove(task.id);
}
