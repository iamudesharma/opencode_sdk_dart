import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'chat_controller.dart';
import 'home_screen.dart';

/// The chat application shell.
class OpenCodeChatApp extends StatelessWidget {
  const OpenCodeChatApp({super.key, required this.controller, this.fontFamily});

  final ChatController controller;

  /// Overrides the default text family; null uses the platform font.
  /// Preview tests load a real face and pass its family here.
  final String? fontFamily;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: controller.themeMode,
      builder: (context, themeMode, _) => MaterialApp(
        title: 'OpenCode Chat',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(Brightness.light, fontFamily: fontFamily),
        darkTheme: buildAppTheme(Brightness.dark, fontFamily: fontFamily),
        themeMode: themeMode,
        home: HomeScreen(controller: controller),
      ),
    );
  }
}
