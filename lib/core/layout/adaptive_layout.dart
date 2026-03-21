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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        debugPrint("LAYOUT WIDTH: $width | isWeb: $kIsWeb");


        if (!kIsWeb) {
          if (width >= 700) {
            return tablet;
          }
          return mobile;
        }


        if (width >= 1000) {
          return webDesktop;
        }

        if (width >= 700) {
          return tablet;
        }

        return mobile;
      },
    );
  }
}