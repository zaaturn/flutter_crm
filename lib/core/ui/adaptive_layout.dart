import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Production-ready layout decisions.
///
/// Key rule: Desktop platforms should not switch to "mobile UI" just because
/// the app window is narrow (e.g. user resizes on a laptop).
abstract final class AdaptiveLayout {
  /// Desktop-like platforms: Windows/macOS/Linux/Web.
  static bool isDesktopLikePlatform() {
    if (kIsWeb) return true;
    return switch (defaultTargetPlatform) {
      TargetPlatform.windows ||
      TargetPlatform.macOS ||
      TargetPlatform.linux =>
        true,
      _ => false,
    };
  }

  /// True when we should render mobile UI.
  ///
  /// Mobile UI should be used on Android/iOS only.
  static bool useMobileUi(BuildContext context) {
    if (isDesktopLikePlatform()) return false;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      _ => MediaQuery.sizeOf(context).width < 900,
    };
  }

  /// Wide layout breakpoint, only relevant for mobile/tablet platforms.
  static bool isWide(BuildContext context) =>
      !useMobileUi(context) || MediaQuery.sizeOf(context).width >= 900;
}

