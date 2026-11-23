import 'package:flutter/material.dart';

import '../state/task_store.dart';
import 'screens.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.store, required this.id});
  final TaskStore store;
  final String id;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final task = store.byId(id);
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle de tarea')),
        body: task == null
            ? const Center(child: Text('Esta tarea se ha eliminado.'))
            : content(
                ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Chip(
                        avatar: Icon(
                          task.completed ? Icons.check_circle : Icons.schedule,
                          size: 18,
                        ),
                        label: Text(
                          task.completed ? 'Completada' : 'Pendiente',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DESCRIPCIÓN',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              task.description.isEmpty
                                  ? 'Sin descripción.'
                                  : task.description,
                              style: const TextStyle(height: 1.6, fontSize: 16),
                            ),
                            const Divider(height: 36),
                            Row(
                              children: [
                                const Icon(Icons.folder_outlined),
                                const SizedBox(width: 12),
                                Text(task.category),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(Icons.calendar_month_outlined),
                                const SizedBox(width: 12),
                                Text(
                                  task.dueDate == null
                                      ? 'Sin fecha límite'
                                      : dateLabel(task.dueDate!),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => store.toggle(task),
                      icon: Icon(task.completed ? Icons.undo : Icons.check),
                      label: Text(
                        task.completed
                            ? 'Marcar como pendiente'
                            : 'Marcar como completada',
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => open(
                        context,
                        TaskFormScreen(store: store, task: task),
                      ),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Editar tarea'),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () async {
                        await deleteTask(context, store, task);
                        if (context.mounted && store.byId(id) == null) {
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Eliminar tarea'),
                    ),
                    if (store.error != null)
                      Text(
                        store.error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                  ],
                ),
              ),
      );
    },
  );
}
