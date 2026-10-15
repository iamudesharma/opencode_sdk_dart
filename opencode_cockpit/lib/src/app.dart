import 'package:flutter/material.dart';

import 'cockpit_controller.dart';
import 'shell.dart';
import 'theme.dart';

/// The cockpit application shell.
class CockpitApp extends StatelessWidget {
  const CockpitApp({super.key, required this.controller});

  final CockpitController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => MaterialApp(
        title: 'OpenCode Cockpit',
        debugShowCheckedModeBanner: false,
        theme: buildCockpitTheme(Brightness.light),
        darkTheme: buildCockpitTheme(Brightness.dark),
        themeMode: controller.themeMode,
        home: CockpitShell(controller: controller),
      ),
    );
  }
}
