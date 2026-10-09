import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_app/admin_settings/admin_palette.dart';

/// Form pieces shared by the Add holiday dialog and the Add/Edit user form,
/// in the dashboard's style (see AssignTaskScreenDesktop): a small label
/// above, a soft rounded box below, nothing floating inside the box.

TextStyle adminFont({
  double size = 14,
  FontWeight weight = FontWeight.w600,
  Color? color,
  double? letterSpacing,
  double? height,
}) =>
    GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );

const double kAdminFieldHeight = 48;

/// The input box itself. No label inside — [AdminField] puts it above.
InputDecoration adminBox(
  AdminPalette p, {
  String? hint,
  IconData? icon,
  Widget? suffix,
}) {
  OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
  return InputDecoration(
    hintText: hint,
    hintStyle: adminFont(color: p.muted.withValues(alpha: 0.7), weight: FontWeight.w500),
    prefixIcon: icon == null ? null : Icon(icon, size: 20, color: p.muted),
    suffixIcon: suffix,
    isDense: true,
    filled: true,
    fillColor: p.surfaceMuted,
    // Sized so text boxes, dropdowns and date boxes are all ~48px and line up.
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
    counterText: '',
    errorStyle: adminFont(size: 12, color: p.danger, weight: FontWeight.w600),
    border: border(p.border),
    enabledBorder: border(p.border),
    focusedBorder: border(p.primary, 1.6),
    errorBorder: border(p.danger),
    focusedErrorBorder: border(p.danger, 1.6),
  );
}

/// Label on top, field underneath, optional hint line below.
class AdminField extends StatelessWidget {
  const AdminField({
    super.key,
    required this.label,
    required this.child,
    this.required = false,
    this.helper,
  });

  final String label;
  final Widget child;
  final bool required;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    final p = AdminPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text.rich(
            TextSpan(
              text: label,
              children: [
                if (required) TextSpan(text: ' *', style: adminFont(size: 13, color: p.danger)),
              ],
            ),
            style: adminFont(size: 13, weight: FontWeight.w700, color: p.text),
          ),
        ),
        child,
        if (helper != null)
          Padding(
            padding: const EdgeInsets.only(left: 2, top: 6),
            child: Text(helper!, style: adminFont(size: 12, weight: FontWeight.w500, color: p.muted)),
          ),
      ],
    );
  }
}

/// A tappable box that shows a date and opens a picker.
class AdminDateBox extends StatelessWidget {
  const AdminDateBox({
    super.key,
    required this.value,
    required this.onTap,
    this.hint = 'Select a date',
    this.onClear,
    this.format = 'EEE, d MMM yyyy',
  });

  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final String hint;
  final String format;

  @override
  Widget build(BuildContext context) {
    final p = AdminPalette.of(context);
    return Material(
      color: p.surfaceMuted,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: kAdminFieldHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: p.border),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_month_rounded, size: 19, color: p.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value == null ? hint : DateFormat(format).format(value!),
                  style: adminFont(
                    weight: value == null ? FontWeight.w500 : FontWeight.w600,
                    color: value == null ? p.muted.withValues(alpha: 0.7) : p.text,
                  ),
                ),
              ),
              if (value != null && onClear != null)
                InkWell(
                  onTap: onClear,
                  borderRadius: BorderRadius.circular(20),
                  child: Icon(Icons.close_rounded, size: 18, color: p.muted),
                )
              else
                Icon(Icons.expand_more_rounded, size: 20, color: p.muted),
            ],
          ),
        ),
      ),
    );
  }
}

/// A dropdown in the same box style.
class AdminDropdown<T> extends StatelessWidget {
  const AdminDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = AdminPalette.of(context);
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      isExpanded: true,
      borderRadius: BorderRadius.circular(12),
      dropdownColor: p.surface,
      icon: Icon(Icons.expand_more_rounded, color: p.muted),
      style: adminFont(color: p.text),
      decoration: adminBox(p),
    );
  }
}

/// The dialog frame: icon + title + subtitle on top, fields in the middle,
/// Cancel / primary action at the bottom.
class AdminFormDialog extends StatelessWidget {
  const AdminFormDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.children,
    required this.primaryLabel,
    required this.onPrimary,
    this.subtitle,
    this.busy = false,
    this.error,
    this.width = 440,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final bool busy;
  final String? error;
  final double width;

  @override
  Widget build(BuildContext context) {
    final p = AdminPalette.of(context);
    return Dialog(
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: p.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: p.primaryDark, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: adminFont(size: 18, weight: FontWeight.w800, color: p.text)),
                        if (subtitle != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            subtitle!,
                            style: adminFont(size: 13, weight: FontWeight.w500, color: p.muted, height: 1.35),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: busy ? null : () => Navigator.pop(context, false),
                    icon: Icon(Icons.close_rounded, color: p.muted),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...children,
                    if (error != null) ...[
                      const SizedBox(height: 14),
                      AdminErrorBanner(message: error!),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: p.border))),
              child: Row(
                children: [
                  Expanded(
                    child: AdminButton(
                      label: 'Cancel',
                      outlined: true,
                      onPressed: busy ? null : () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AdminButton(label: primaryLabel, busy: busy, onPressed: onPrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminButton extends StatelessWidget {
  const AdminButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.outlined = false,
    this.busy = false,
    this.icon,
    this.height = 48,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  final bool busy;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = AdminPalette.of(context);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
    final text = Text(label, style: adminFont(size: 15, weight: FontWeight.w800));
    final content = busy
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: outlined ? p.primary : Colors.white,
            ),
          )
        : icon == null
            ? text
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(icon, size: 19), const SizedBox(width: 8), text],
              );
    return SizedBox(
      height: height,
      child: outlined
          ? OutlinedButton(
              onPressed: busy ? null : onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: p.text,
                side: BorderSide(color: p.border, width: 1.4),
                shape: shape,
              ),
              child: content,
            )
          : FilledButton(
              onPressed: busy ? null : onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: p.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: p.primary.withValues(alpha: 0.45),
                disabledForegroundColor: Colors.white,
                shape: shape,
                elevation: 0,
              ),
              child: content,
            ),
    );
  }
}

class AdminErrorBanner extends StatelessWidget {
  const AdminErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final p = AdminPalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: p.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.danger.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: p.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: adminFont(size: 13, color: p.danger, height: 1.35)),
          ),
        ],
      ),
    );
  }
}

/// Section heading inside long forms ("LOGIN", "PERSONAL DETAILS").
class AdminSectionTitle extends StatelessWidget {
  const AdminSectionTitle(this.title, {super.key, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final p = AdminPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: adminFont(size: 16, weight: FontWeight.w800, color: p.text)),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(subtitle!, style: adminFont(size: 13, weight: FontWeight.w500, color: p.muted)),
        ],
      ],
    );
  }
}
