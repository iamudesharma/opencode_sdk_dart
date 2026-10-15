import 'package:flutter/material.dart';

import 'chat_controller.dart';
import 'home_screen.dart';

/// The chat application shell.
class OpenCodeChatApp extends StatelessWidget {
  const OpenCodeChatApp({super.key, required this.controller});

  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenCode Chat',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: HomeScreen(controller: controller),
    );
  }

  static ThemeData _buildTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF7C6CF0),
      brightness: Brightness.dark,
      surface: const Color(0xFF121317),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF0E0F13),
      fontFamily: 'AppFont',
      visualDensity: VisualDensity.compact,
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.35),
        thickness: 1,
      ),
      tooltipTheme: const TooltipThemeData(waitDuration: Duration(milliseconds: 400)),
      scrollbarTheme: ScrollbarThemeData(
        thumbVisibility: WidgetStateProperty.all(false),
        thickness: WidgetStateProperty.all(7),
        radius: const Radius.circular(4),
      ),
    );
  }
}
