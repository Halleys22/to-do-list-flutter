import 'package:flutter/material.dart';

import '../state/task_store.dart';
import 'screens.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.store});
  final TaskStore store;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [
        IconButton(
          tooltip: 'Cambiar tema',
          onPressed: store.toggleTheme,
          icon: Icon(
            store.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          ),
        ),
      ],
    ),
    body: content(
      SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TU DÍA, CON MÁS CALMA',
              style: TextStyle(
                letterSpacing: 2,
                fontWeight: FontWeight.w700,
                color: Color(0xff7583e7),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(Icons.checklist_rounded, size: 100),
            ),
            const SizedBox(height: 36),
            Text(
              'TO DO LIST',
              style: Theme.of(context).textTheme.displaySmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            Text(
              'Pequeños pasos.\nGrandes días.',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const Text(
              'Organiza tus tareas, encuentra tu enfoque y celebra cada avance. Todo lo que necesitas, en un solo lugar.',
              style: TextStyle(fontSize: 17, height: 1.6),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => open(context, TaskListScreen(store: store)),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Ver mis tareas'),
            ),
            const SizedBox(height: 24),
            const Row(
              children: [
                Icon(Icons.save_outlined, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Tus tareas se guardan en este dispositivo.'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
