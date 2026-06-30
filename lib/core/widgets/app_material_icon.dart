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
    final style = TextStyle(
      inherit: false,
      fontFamily: icon.fontFamily ?? 'MaterialIcons',
      fontSize: size,
      color: color,
      height: 1,
    );
    if (icon.fontPackage != null) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(
            String.fromCharCode(icon.codePoint),
            style: style.copyWith(package: icon.fontPackage),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Text(
          String.fromCharCode(icon.codePoint),
          style: style,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
