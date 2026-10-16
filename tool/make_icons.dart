// ignore_for_file: avoid_print
/// Generates the branded app icons for the three apps (web + macOS).
///
/// ```sh
/// dart run tool/make_icons.dart
/// ```
///
/// Pure Dart (`package:image`): each brand's master icon is drawn at 2048 px
/// and downscaled with cubic interpolation, then written to:
///
/// * `web/icons/Icon-192.png`, `Icon-512.png`, `Icon-maskable-*.png` and
///   `web/favicon.png` — full-bleed (no transparency: iOS paints transparent
///   `apple-touch-icon` corners black);
/// * `macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_*.png` — the
///   macOS rounded-square treatment with transparent corners.
library;

import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

/// Master drawing size; everything is downscaled from here.
const int _master = 2048;

/// macOS-style corner radius, as a fraction of the icon size.
const double _macRadius = 0.22;

void main() {
  final root = p.dirname(p.dirname(Platform.script.toFilePath()));
  for (final brand in _brands) {
    final master = brand.draw();
    _writeWeb(root, brand.app, master);
    _writeMacos(root, brand.app, master);
    print('icons: ${brand.app} done');
  }
}

// ---------------------------------------------------------------------------
// Brands
// ---------------------------------------------------------------------------

/// One app brand: a background painter plus a glyph painter.
final class _Brand {
  const _Brand({
    required this.app,
    required this.background,
    required this.glyph,
  });

  /// App directory name, for example `gym_coach`.
  final String app;

  /// Paints the full-bleed background of [size] pixels.
  final img.Color Function(img.Image image) background;

  /// Paints the glyph on top of the background.
  final void Function(img.Image image, img.Color color) glyph;

  /// Draws the master icon.
  img.Image draw() {
    final image = img.Image(width: _master, height: _master, numChannels: 4);
    final foreground = background(image);
    glyph(image, foreground);
    return image;
  }
}

final List<_Brand> _brands = [
  _Brand(
    app: 'gym_coach',
    background: (image) {
      _verticalGradient(
        image,
        img.ColorRgba8(0x2E, 0xBD, 0x6E, 0xFF),
        img.ColorRgba8(0x54, 0xD9, 0x8C, 0xFF),
      );
      return img.ColorRgba8(0x14, 0x16, 0x1A, 0xFF);
    },
    glyph: _dumbbell,
  ),
  _Brand(
    app: 'chat_app',
    background: (image) {
      _verticalGradient(
        image,
        img.ColorRgba8(0x8B, 0x7C, 0xF6, 0xFF),
        img.ColorRgba8(0x4F, 0xC3, 0xF7, 0xFF),
      );
      return img.ColorRgba8(0xFF, 0xFF, 0xFF, 0xFF);
    },
    glyph: _chatBubble,
  ),
  _Brand(
    app: 'opencode_cockpit',
    background: (image) {
      _verticalGradient(
        image,
        img.ColorRgba8(0x8B, 0x7C, 0xF6, 0xFF),
        img.ColorRgba8(0x4F, 0xC3, 0xF7, 0xFF),
      );
      return img.ColorRgba8(0xFF, 0xFF, 0xFF, 0xFF);
    },
    glyph: _terminalWindow,
  ),
];

// ---------------------------------------------------------------------------
// Glyphs (all coordinates are fractions of the master size)
// ---------------------------------------------------------------------------

void _dumbbell(img.Image image, img.Color color) {
  final s = image.width;
  final center = s ~/ 2;
  final barHalf = (0.055 * s / 2).round();
  img.fillRect(
    image,
    x1: (0.32 * s).round(),
    y1: center - barHalf,
    x2: (0.68 * s).round(),
    y2: center + barHalf,
    color: color,
  );
  const plates = [
    (0.34, 0.085),
    (0.66, 0.085),
    (0.275, 0.06),
    (0.725, 0.06),
  ];
  for (final (x, radius) in plates) {
    img.fillCircle(
      image,
      x: (x * s).round(),
      y: center,
      radius: (radius * s).round(),
      color: color,
    );
  }
}

void _chatBubble(img.Image image, img.Color color) {
  final s = image.width;
  _fillRoundedRect(
    image,
    x1: (0.27 * s).round(),
    y1: (0.27 * s).round(),
    x2: (0.73 * s).round(),
    y2: (0.60 * s).round(),
    radius: (0.085 * s).round(),
    color: color,
  );
  img.fillPolygon(
    image,
    vertices: [
      img.Point((0.33 * s).round(), (0.585 * s).round()),
      img.Point((0.265 * s).round(), (0.735 * s).round()),
      img.Point((0.47 * s).round(), (0.585 * s).round()),
    ],
    color: color,
  );
}

void _terminalWindow(img.Image image, img.Color color) {
  final s = image.width;
  final x1 = (0.26 * s).round();
  final y1 = (0.27 * s).round();
  final x2 = (0.74 * s).round();
  final y2 = (0.73 * s).round();
  final thickness = (0.035 * s).round();
  img.drawRect(
    image,
    x1: x1,
    y1: y1,
    x2: x2,
    y2: y2,
    color: color,
    thickness: thickness,
  );
  img.fillRect(
    image,
    x1: x1,
    y1: y1,
    x2: x2,
    y2: y1 + (0.10 * s).round(),
    color: color,
  );
  final px = (0.365 * s).round();
  final py = (0.475 * s).round();
  final tip = (px + 0.075 * s).round();
  final mid = (py + 0.065 * s).round();
  img.drawLine(
    image,
    x1: px,
    y1: py,
    x2: tip,
    y2: mid,
    color: color,
    thickness: thickness,
    antialias: true,
  );
  img.drawLine(
    image,
    x1: tip,
    y1: mid,
    x2: px,
    y2: (py + 0.13 * s).round(),
    color: color,
    thickness: thickness,
    antialias: true,
  );
  img.drawLine(
    image,
    x1: (0.505 * s).round(),
    y1: (0.605 * s).round(),
    x2: (0.635 * s).round(),
    y2: (0.605 * s).round(),
    color: color,
    thickness: thickness,
    antialias: true,
  );
}

// ---------------------------------------------------------------------------
// Painting helpers
// ---------------------------------------------------------------------------

/// Fills [image] with a vertical gradient from [top] to [bottom].
void _verticalGradient(img.Image image, img.Color top, img.Color bottom) {
  final height = image.height;
  for (var y = 0; y < height; y++) {
    final t = y / (height - 1);
    img.fillRect(
      image,
      x1: 0,
      y1: y,
      x2: image.width - 1,
      y2: y,
      color: img.ColorRgba8(
        (top.r + (bottom.r - top.r) * t).round(),
        (top.g + (bottom.g - top.g) * t).round(),
        (top.b + (bottom.b - top.b) * t).round(),
        255,
      ),
    );
  }
}

/// Fills a rounded rectangle (anti-aliasing comes from the downscale).
void _fillRoundedRect(
  img.Image image, {
  required int x1,
  required int y1,
  required int x2,
  required int y2,
  required int radius,
  required img.Color color,
}) {
  final left = x1 + radius;
  final top = y1 + radius;
  final right = x2 - radius;
  final bottom = y2 - radius;
  final radiusSquared = radius * radius;
  for (var y = y1; y <= y2; y++) {
    for (var x = x1; x <= x2; x++) {
      final inCross = (x >= left && x <= right) || (y >= top && y <= bottom);
      var inside = inCross;
      if (!inside) {
        final cornerX = x < left ? left : right;
        final cornerY = y < top ? top : bottom;
        final dx = x - cornerX;
        final dy = y - cornerY;
        inside = dx * dx + dy * dy <= radiusSquared;
      }
      if (inside) image.setPixel(x, y, color);
    }
  }
}

/// Clears everything outside a rounded rectangle (macOS icon shape).
void _applyRoundedMask(img.Image image, int radius) {
  final width = image.width;
  final height = image.height;
  final left = radius;
  final top = radius;
  final right = width - 1 - radius;
  final bottom = height - 1 - radius;
  final radiusSquared = radius * radius;
  final transparent = img.ColorRgba8(0, 0, 0, 0);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final inCross = (x >= left && x <= right) || (y >= top && y <= bottom);
      if (inCross) continue;
      final cornerX = x < left ? left : right;
      final cornerY = y < top ? top : bottom;
      final dx = x - cornerX;
      final dy = y - cornerY;
      if (dx * dx + dy * dy > radiusSquared) {
        image.setPixel(x, y, transparent);
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Output
// ---------------------------------------------------------------------------

img.Image _resize(img.Image master, int size) => img.copyResize(
  master,
  width: size,
  height: size,
  interpolation: img.Interpolation.cubic,
);

void _writePng(String path, img.Image image) {
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(img.encodePng(image));
  print('  wrote ${p.relative(path)}');
}

void _writeWeb(String root, String app, img.Image master) {
  final icons = p.join(root, app, 'web', 'icons');
  for (final size in const [192, 512]) {
    final icon = _resize(master, size);
    _writePng(p.join(icons, 'Icon-$size.png'), icon);
    _writePng(p.join(icons, 'Icon-maskable-$size.png'), icon);
  }
  _writePng(p.join(root, app, 'web', 'favicon.png'), _resize(master, 32));
}

void _writeMacos(String root, String app, img.Image master) {
  final rounded = _resize(master, _master);
  _applyRoundedMask(rounded, (_macRadius * _master).round());
  final appiconset = p.join(
    root,
    app,
    'macos',
    'Runner',
    'Assets.xcassets',
    'AppIcon.appiconset',
  );
  for (final size in const [16, 32, 64, 128, 256, 512, 1024]) {
    _writePng(p.join(appiconset, 'app_icon_$size.png'), _resize(rounded, size));
  }
}
