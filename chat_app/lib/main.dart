import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/chat_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OpenCodeChat());
}

/// Hosts the controller for the lifetime of the app.
class OpenCodeChat extends StatefulWidget {
  const OpenCodeChat({super.key});

  @override
  State<OpenCodeChat> createState() => _OpenCodeChatState();
}

class _OpenCodeChatState extends State<OpenCodeChat> {
  final ChatController _controller = ChatController();

  @override
  void initState() {
    super.initState();
    // Try the local service on launch; the connect screen remains available
    // when discovery fails.
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
  Widget build(BuildContext context) => OpenCodeChatApp(controller: _controller);
}
