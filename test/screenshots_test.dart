// Capturas reproducibles de pantallas Flutter a 430 x 932 píxeles lógicos.
import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_list_flutter/main.dart';
import 'package:to_do_list_flutter/models/task.dart';
import 'package:to_do_list_flutter/state/task_store.dart';

void main() {
  testWidgets('Capturas de todas las pantallas', (tester) async {
    debugDisableShadows = false;
    addTearDown(() => debugDisableShadows = true);
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      final configFile = File('.dart_tool/package_config.json').absolute;
      final config =
          jsonDecode(configFile.readAsStringSync()) as Map<String, dynamic>;
      final flutterPackage = (config['packages'] as List).firstWhere(
        (p) => p['name'] == 'flutter',
      );
      final sdk = Directory.fromUri(
        configFile.uri.resolve(flutterPackage['rootUri'] as String),
      ).parent.parent.path;
      final directory = '$sdk/bin/cache/artifacts/material_fonts';
      final font = FontLoader('Roboto')
        ..addFont(
          Future.value(
            ByteData.sublistView(
              File('$directory/roboto-regular.ttf').readAsBytesSync(),
            ),
          ),
        );
      final icons = FontLoader('MaterialIcons')
        ..addFont(
          Future.value(
            ByteData.sublistView(
              File('$directory/materialicons-regular.otf').readAsBytesSync(),
            ),
          ),
        );
      await font.load();
      await icons.load();
    });
    SharedPreferences.setMockInitialValues({});
    final store = TaskStore(await SharedPreferences.getInstance());
    final boundary = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: TodoApp(store: store),
      ),
    );
    Future<void> capture(String name) async {
      await tester.pumpAndSettle();
      final render =
          boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await render.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final directory = Directory('entrega/capturas')
          ..createSync(recursive: true);
        await File('${directory.path}/$name.png')
            .writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      expect(tester.takeException(), isNull);
    }

    await capture('01_bienvenida');
    await tester.tap(find.text('Ver mis tareas'));
    await capture('02_lista_vacia');
    await store.save(
      Task(
        id: '1',
        title: 'Preparar la entrega de Flutter',
        description: 'Revisar la aplicación, comprimir el proyecto y adjuntar las capturas de cada pantalla.',
        category: 'Estudios',
        dueDate: DateTime(2026, 10, 20),
      ),
    );
    await store.save(
      const Task(
        id: '2',
        title: 'Leer un capítulo',
        description: 'Reservar un momento para aprender algo nuevo.',
        completed: true,
      ),
    );
    await capture('03_lista_tareas');
    await tester.tap(find.text('Nueva tarea'));
    await capture('04_nueva_tarea');
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Preparar la entrega de Flutter'));
    await capture('05_detalle');
    await tester.tap(find.text('Editar tarea'));
    await capture('06_editar_tarea');
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await store.toggleTheme();
    await capture('07_modo_oscuro');
    debugDisableShadows = true;
  });
}

