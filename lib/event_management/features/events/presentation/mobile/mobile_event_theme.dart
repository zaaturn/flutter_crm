import 'package:flutter/material.dart';

import '../../../calendar/presentation/mobile/mobile_calendar_theme.dart';

/// Shared terracotta / cream theme for mobile event CRUD screens.
abstract final class MobileEventTheme {
  static const background = MobileCalendarTheme.background;
  static const terracotta = MobileCalendarTheme.terracotta;
  static const terracottaDark = MobileCalendarTheme.terracottaDark;
  static const segmentBg = MobileCalendarTheme.segmentBg;
  static const field = MobileCalendarTheme.segmentBg;
  static const card = MobileCalendarTheme.card;
  static const textDark = MobileCalendarTheme.textDark;
  static const textMuted = MobileCalendarTheme.textMuted;
  static const border = MobileCalendarTheme.border;
  static const selectedCell = MobileCalendarTheme.selectedCell;

  static ThemeData themeData(BuildContext context) {
    final base = Theme.of(context);
    const scheme = ColorScheme.light(
      primary: terracotta,
      onPrimary: Colors.white,
      secondary: terracotta,
      onSecondary: Colors.white,
      surface: background,
      onSurface: textDark,
    );
    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: scheme,
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: terracotta),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return Colors.grey.shade400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return terracotta;
          return Colors.grey.shade300;
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: terracotta,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: terracotta,
          side: const BorderSide(color: terracotta),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: terracotta),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: field,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: terracotta, width: 1.5),
        ),
      ),
      dividerColor: border,
      dialogTheme: const DialogThemeData(
        backgroundColor: card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: terracotta,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static Widget wrap(BuildContext context, Widget child) {
    return Theme(data: themeData(context), child: child);
  }

  static ButtonStyle filledButton({EdgeInsetsGeometry? padding}) {
    return FilledButton.styleFrom(
      backgroundColor: terracotta,
      foregroundColor: Colors.white,
      padding: padding ?? const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}
