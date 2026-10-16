import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A one-click clipboard copy button that briefly shows a checkmark.
class CopyButton extends StatefulWidget {
  const CopyButton({
    super.key,
    required this.text,
    this.color = const Color(0xFF9BA3B8),
    this.copiedColor = const Color(0xFF6EE7A8),
    this.fontSize = 11.5,
  });

  /// The text placed on the clipboard.
  final String text;

  final Color color;
  final Color copiedColor;
  final double fontSize;

  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  Timer? _resetTimer;
  var _copied = false;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    if (!mounted) return;
    setState(() => _copied = true);
    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: _copy,
      icon: Icon(
        _copied ? Icons.check_rounded : Icons.copy_rounded,
        size: 13,
      ),
      label: Text(
        _copied ? 'Copied' : 'Copy',
        // Merges with the button's themed text style (keeps its font family).
        style: TextStyle(fontSize: widget.fontSize),
      ),
      style: TextButton.styleFrom(
        foregroundColor: _copied ? widget.copiedColor : widget.color,
        minimumSize: const Size(0, 26),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }
}
