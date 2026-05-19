import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AdaptiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget webDesktop;

  const AdaptiveLayout({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.webDesktop,
  });

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  bool _isRealMobile(BuildContext context) {
    return !kIsWeb &&
        (Theme.of(context).platform == TargetPlatform.android ||
            Theme.of(context).platform == TargetPlatform.iOS);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        debugPrint("LAYOUT WIDTH: $width | isWeb: $kIsWeb");

        if (_isRealMobile(context)) {
          if (width < mobileBreakpoint) {
            return mobile;
          } else {
            return tablet;
          }
        }

        if (width >= tabletBreakpoint) {
          return webDesktop;
        } else if (width >= mobileBreakpoint) {
          return tablet;
        } else {
          return webDesktop;
        }
      },
    );
  }
}