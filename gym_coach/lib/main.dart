import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:marionette_flutter/marionette_flutter.dart';

import 'src/home_screen.dart';

void main() {
  // In debug builds the marionette binding exposes the widget tree to the
  // marionette MCP tools (see README → "Driving the app").
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized();
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }
  runApp(const GymCoachApp());
}

/// The app's dark theme, shared with tests so they render the real thing.
ThemeData gymCoachTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF54D98C),
    brightness: Brightness.dark,
  );
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFF14161A),
    cardTheme: const CardThemeData(margin: EdgeInsets.zero),
  );
}

class GymCoachApp extends StatelessWidget {
  const GymCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Coach',
      debugShowCheckedModeBanner: false,
      theme: gymCoachTheme(),
      home: const HomeScreen(),
    );
  }
}
