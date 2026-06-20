import 'package:flutter/material.dart';

/// Renders a Material icon using the bundled [MaterialIcons] font explicitly.
/// Avoids missing glyphs on web when the app theme sets a custom [fontFamily].
class AppMaterialIcon extends StatelessWidget {
  const AppMaterialIcon(
    this.icon, {
    super.key,
    this.size = 24,
    this.color,
  });

  final IconData icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size,
      color: color,
      textDirection: TextDirection.ltr,
      applyTextScaling: false,
    );
  }
}
