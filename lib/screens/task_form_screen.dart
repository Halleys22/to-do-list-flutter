import 'package:flutter/material.dart';

import '../models/task.dart';
import '../state/task_store.dart';
import 'screens.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, required this.store, this.task});
  final TaskStore store;
  final Task? task;
  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController title, description;
  late String category;
  DateTime? dueDate;
  bool saving = false;
  @override
  void initState() {
    super.initState();
    title = TextEditingController(text: widget.task?.title);
    description = TextEditingController(text: widget.task?.description);
    category = widget.task?.category ?? categories.first;
    dueDate = widget.task?.dueDate;
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.task == null ? 'Nueva tarea' : 'Editar tarea'),
    ),
    body: content(
      SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.task == null
                    ? '¿Qué quieres conseguir?'
                    : 'Cada plan puede cambiar.',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Dale un nombre a tu próximo paso.'),
              const SizedBox(height: 28),
              TextFormField(
                controller: title,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'Título *',
                  hintText: 'Ej. Preparar la entrega de Flutter',
                  prefixIcon: Icon(Icons.edit_outlined),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Introduce un título para la tarea.'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: description,
                maxLines: 4,
                maxLength: 1000,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Añade los detalles que te ayudarán…',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  prefixIcon: Icon(Icons.folder_outlined),
                ),
                items: categories
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => category = value!),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 0,
                child: ListTile(
                  leading: const Icon(Icons.calendar_month_outlined),
                  title: const Text('Fecha límite'),
                  subtitle: Text(
                    dueDate == null
                        ? 'Opcional · sin fecha'
                        : dateLabel(dueDate!),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: dueDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      helpText: 'Selecciona la fecha límite',
                      cancelText: 'Cancelar',
                      confirmText: 'Aceptar',
                    );
                    if (picked != null && mounted) {
                      setState(() => dueDate = picked);
                    }
                  },
                  trailing: dueDate == null
                      ? const Icon(Icons.chevron_right)
                      : IconButton(
                          tooltip: 'Quitar fecha',
                          onPressed: () => setState(() => dueDate = null),
                          icon: const Icon(Icons.close),
                        ),
                ),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: saving
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        setState(() => saving = true);
                        await widget.store.save(
                          Task(
                            id:
                                widget.task?.id ??
                                DateTime.now().microsecondsSinceEpoch
                                    .toString(),
                            title: title.text.trim(),
                            description: description.text.trim(),
                            category: category,
                            dueDate: dueDate,
                            completed: widget.task?.completed ?? false,
                          ),
                        );
                        if (!context.mounted) return;
                        if (widget.store.error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(widget.store.error!)),
                          );
                          setState(() => saving = false);
                        } else {
                          Navigator.pop(context);
                        }
                      },
                icon: const Icon(Icons.check),
                label: Text(saving ? 'Guardando…' : 'Guardar tarea'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
