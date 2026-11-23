import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'state/task_store.dart';
import 'screens/screens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(TodoApp(store: TaskStore(await SharedPreferences.getInstance())));
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key, required this.store});
  final TaskStore store;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => MaterialApp(
      title: 'TO DO LIST',
      debugShowCheckedModeBanner: false,
      themeMode: store.dark ? ThemeMode.dark : ThemeMode.light,
      theme: theme(Brightness.light),
      darkTheme: theme(Brightness.dark),
      home: WelcomeScreen(store: store),
    ),
  );
  ThemeData theme(Brightness brightness) => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xff5265db),
      brightness: brightness,
    ),
    scaffoldBackgroundColor: brightness == Brightness.light
        ? const Color(0xfff6f7fb)
        : const Color(0xff141722),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}
