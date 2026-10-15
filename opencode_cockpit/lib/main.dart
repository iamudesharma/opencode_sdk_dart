import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/cockpit_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OpenCodeCockpit());
}

/// Hosts the controller for the lifetime of the app.
class OpenCodeCockpit extends StatefulWidget {
  const OpenCodeCockpit({super.key});

  @override
  State<OpenCodeCockpit> createState() => _OpenCodeCockpitState();
}

class _OpenCodeCockpitState extends State<OpenCodeCockpit> {
  final CockpitController _controller = CockpitController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.connectLocal();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CockpitApp(controller: _controller);
}
