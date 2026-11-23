import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

/// ChangeNotifier sincroniza las pantallas. SharedPreferences conserva el estado.
class TaskStore extends ChangeNotifier {
  TaskStore(this.preferences) {
    dark = preferences.getBool('dark') ?? false;
    try {
      final data = jsonDecode(preferences.getString('tasks') ?? '[]') as List;
      _tasks.addAll(
        data.map((item) => Task.fromJson(item as Map<String, dynamic>)),
      );
    } catch (_) {
      error = 'No se pudieron leer las tareas guardadas.';
    }
  }
  final SharedPreferences preferences;
  final List<Task> _tasks = [];
  List<Task> get tasks => List.unmodifiable(_tasks);
  bool dark = false;
  String? error;
  int get completed => _tasks.where((task) => task.completed).length;
  double get progress => _tasks.isEmpty ? 0 : completed / _tasks.length;
  Task? byId(String id) {
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  Future<void> save(Task task) async {
    final index = _tasks.indexWhere((item) => item.id == task.id);
    if (index < 0) {
      _tasks.add(task);
    } else {
      _tasks[index] = task;
    }
    await _persist();
  }

  Future<void> remove(String id) async {
    _tasks.removeWhere((task) => task.id == id);
    await _persist();
  }

  Future<void> toggle(Task task) => save(task.toggle());
  Future<void> _persist() async {
    try {
      final success = await preferences.setString(
        'tasks',
        jsonEncode(_tasks.map((task) => task.toJson()).toList()),
      );
      error = success ? null : 'No se pudieron guardar los cambios.';
    } catch (_) {
      error = 'No se pudieron guardar los cambios.';
    }
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    dark = !dark;
    try {
      await preferences.setBool('dark', dark);
    } catch (_) {
      error = 'No se pudo guardar el tema.';
    }
    notifyListeners();
  }
}
