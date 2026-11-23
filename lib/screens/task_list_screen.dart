import 'package:flutter/material.dart';

import '../state/task_store.dart';
import 'screens.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key, required this.store});
  final TaskStore store;
  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String filter = 'Todas', query = '';
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) {
      final store = widget.store;
      final tasks = store.tasks
          .where(
            (task) =>
                (filter == 'Todas' ||
                    (filter == 'Completadas'
                        ? task.completed
                        : !task.completed)) &&
                '${task.title} ${task.description} ${task.category}'
                    .toLowerCase()
                    .contains(query.toLowerCase()),
          )
          .toList();
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mis tareas'),
          actions: [
            IconButton(
              tooltip: 'Cambiar tema',
              onPressed: store.toggleTheme,
              icon: Icon(
                store.dark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => open(context, TaskFormScreen(store: store)),
          icon: const Icon(Icons.add),
          label: const Text('Nueva tarea'),
        ),
        body: content(
          ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
            children: [
              Text(
                'Haz espacio para lo importante.',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.insights_rounded),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Tu progreso',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Text(
                            '${(store.progress * 100).round()}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: store.progress,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${store.completed} de ${store.tasks.length} tareas completadas · ${store.tasks.length - store.completed} pendientes',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                onChanged: (value) => setState(() => query = value),
                decoration: const InputDecoration(
                  hintText: 'Buscar tareas o categorías',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: ['Todas', 'Pendientes', 'Completadas']
                    .map(
                      (value) => ChoiceChip(
                        label: Text(value),
                        selected: filter == value,
                        onSelected: (_) => setState(() => filter = value),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              if (store.error != null)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    store.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              if (tasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.task_alt,
                        size: 64,
                        color: Color(0xff7583e7),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        store.tasks.isEmpty
                            ? 'Un nuevo comienzo'
                            : 'No hay coincidencias',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        store.tasks.isEmpty
                            ? 'Crea tu primera tarea con el botón «Nueva tarea».'
                            : 'Prueba otra búsqueda o cambia el filtro.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ...tasks.map(
                (task) => Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: IconButton(
                      tooltip: task.completed
                          ? 'Marcar pendiente'
                          : 'Completar tarea',
                      onPressed: () => store.toggle(task),
                      icon: Icon(
                        task.completed
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: task.completed
                            ? Colors.teal
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        decoration: task.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.description.isEmpty
                                ? 'Sin descripción'
                                : task.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${task.category} · ${task.completed ? 'Completada' : 'Pendiente'}${task.dueDate == null ? '' : ' · ${dateLabel(task.dueDate!)}'}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    onTap: () => open(
                      context,
                      TaskDetailScreen(store: store, id: task.id),
                    ),
                    trailing: PopupMenuButton<String>(
                      tooltip: 'Opciones de tarea',
                      onSelected: (value) {
                        if (value == 'edit') {
                          open(
                            context,
                            TaskFormScreen(store: store, task: task),
                          );
                        } else if (value == 'delete') {
                          deleteTask(context, store, task);
                        } else {
                          open(
                            context,
                            TaskDetailScreen(store: store, id: task.id),
                          );
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'detail',
                          child: Text('Ver detalle'),
                        ),
                        PopupMenuItem(value: 'edit', child: Text('Editar')),
                        PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
