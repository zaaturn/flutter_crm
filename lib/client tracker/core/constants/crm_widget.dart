import 'package:flutter/material.dart';
import 'package:my_app/client tracker/core/constants/app_theme.dart';

// ══════════════════════════════════════════════
// CRM CARD
// ══════════════════════════════════════════════
class CrmCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const CrmCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(kRadius),
      border: Border.all(color: AppColors.border),
      boxShadow: const [
        BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1)),
        BoxShadow(color: Color(0x06000000), blurRadius: 16, offset: Offset(0, 4)),
      ],
    ),
    child: padding != null
        ? Padding(padding: padding!, child: child)
        : child,
  );
}

// ══════════════════════════════════════════════
// SECTION CARD  (header + body)
// ══════════════════════════════════════════════
class SectionCard extends StatelessWidget {
  final String title;
  final Widget? titleIcon;
  final Widget? action;
  final Widget child;

  const SectionCard({
    super.key,
    required this.title,
    this.titleIcon,
    this.action,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => CrmCard(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Header
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: const BoxDecoration(
          color: Color(0xFFFAFBFC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(kRadius)),
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(children: [
          if (titleIcon != null) ...[titleIcon!, const SizedBox(width: 8)],
          Text(title, style: AppTextStyles.subheading),
          if (action != null) ...[const Spacer(), action!],
        ]),
      ),
      // Body
      Padding(padding: const EdgeInsets.all(22), child: child),
    ]),
  );
}

// ══════════════════════════════════════════════
// BADGE
// ══════════════════════════════════════════════
enum BadgeType { blue, green, red, yellow }

class CrmBadge extends StatelessWidget {
  final String label;
  final BadgeType type;

  const CrmBadge(this.label, {super.key, this.type = BadgeType.blue});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (type) {
      BadgeType.blue   => (AppColors.primaryLight, AppColors.primary),
      BadgeType.green  => (AppColors.accentLight,  const Color(0xFF137333)),
      BadgeType.red    => (AppColors.dangerLight,  AppColors.danger),
      BadgeType.yellow => (AppColors.warnLight,    const Color(0xFFB7770D)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: AppTextStyles.small.copyWith(color: fg, fontWeight: FontWeight.w700)),
    );
  }
}

// ══════════════════════════════════════════════
// BUTTON
// ══════════════════════════════════════════════
enum BtnStyle { primary, outline, ghost }

class CrmButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final BtnStyle style;
  final Widget? icon;
  final bool loading;
  final double? width;

  const CrmButton(
      this.label, {
        super.key,
        this.onTap,
        this.style = BtnStyle.primary,
        this.icon,
        this.loading = false,
        this.width,
      });

  @override
  State<CrmButton> createState() => _CrmButtonState();
}

class _CrmButtonState extends State<CrmButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, Color borderC) = switch (widget.style) {
      BtnStyle.primary => (AppColors.primary, Colors.white, AppColors.primary),
      BtnStyle.outline => (Colors.transparent, AppColors.primary, AppColors.primary),
      BtnStyle.ghost => (Colors.transparent, AppColors.textMuted, AppColors.border),
    };

    final hoveredBg = switch (widget.style) {
      BtnStyle.primary => AppColors.primaryDark,
      BtnStyle.outline => AppColors.primaryLight,
      BtnStyle.ghost => AppColors.bg,
    };

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.loading ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.width,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: _hovered ? hoveredBg : bg,
            borderRadius: BorderRadius.circular(kRadiusSm),
            border: Border.all(color: borderC, width: 1.5),
            boxShadow: widget.style == BtnStyle.primary
                ? [
              BoxShadow(
                  color: AppColors.primary.withOpacity(.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.loading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                )
              else ...[
                if (widget.icon != null) ...[
                  IconTheme(
                    data: IconThemeData(color: fg, size: 16),
                    child: widget.icon!,
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    widget.label,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label.copyWith(color: fg),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
// ══════════════════════════════════════════════
// TEXT FIELD
// ══════════════════════════════════════════════
class CrmTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool required;
  final bool obscure;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final String? initialValue;

  const CrmTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.required = false,
    this.obscure = false,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.initialValue,
  });

  @override
  State<CrmTextField> createState() => _CrmTextFieldState();
}

class _CrmTextFieldState extends State<CrmTextField> {
  bool _showPass = false;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(widget.label, style: AppTextStyles.label),
        if (widget.required)
          Text(' *', style: AppTextStyles.label.copyWith(color: AppColors.danger)),
      ]),
      const SizedBox(height: 6),
      TextFormField(
        controller: widget.controller,
        initialValue: widget.initialValue,
        maxLines: widget.maxLines,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscure && !_showPass,
        validator: widget.validator,
        onChanged: widget.onChanged,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.textLight),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kRadiusSm),
            borderSide: const BorderSide(color: AppColors.border, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kRadiusSm),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kRadiusSm),
            borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kRadiusSm),
            borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
          ),
          suffixIcon: widget.obscure
              ? GestureDetector(
            onTap: () => setState(() => _showPass = !_showPass),
            child: Icon(
              _showPass
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 18, color: AppColors.textMuted,
            ),
          )
              : null,
        ),
      ),
    ]);
  }
}

// ══════════════════════════════════════════════
// DROPDOWN (styled container)
// ══════════════════════════════════════════════
class CrmDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const CrmDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles.label),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(kRadiusSm),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppColors.textMuted, size: 20),
            style: AppTextStyles.body,
            dropdownColor: AppColors.surface,
            borderRadius: BorderRadius.circular(kRadiusSm),
          ),
        ),
      ),
    ],
  );
}

// ══════════════════════════════════════════════
// STATUS PILL DROPDOWN  (Yes / No)
// ══════════════════════════════════════════════
class StatusPillDropdown extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const StatusPillDropdown({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final bg = value ? AppColors.accentLight  : AppColors.dangerLight;
    final fg = value ? const Color(0xFF137333) : AppColors.danger;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<bool>(
          value: value,
          isDense: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: fg, size: 16),
          dropdownColor: AppColors.surface,
          borderRadius: BorderRadius.circular(kRadiusSm),
          items: [
            DropdownMenuItem(
              value: true,
              child: Text('Yes',
                  style: AppTextStyles.small.copyWith(
                      color: const Color(0xFF137333), fontWeight: FontWeight.w700)),
            ),
            DropdownMenuItem(
              value: false,
              child: Text('No',
                  style: AppTextStyles.small.copyWith(
                      color: AppColors.danger, fontWeight: FontWeight.w700)),
            ),
          ],
          selectedItemBuilder: (_) => [
            Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('Yes', style: AppTextStyles.small.copyWith(color: fg, fontWeight: FontWeight.w700))),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('No',  style: AppTextStyles.small.copyWith(color: fg, fontWeight: FontWeight.w700))),
          ],
          onChanged: (v) => v != null ? onChanged(v) : null,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// CLIENT AVATAR
// ══════════════════════════════════════════════
class ClientAvatar extends StatelessWidget {
  final String name;
  final double size;
  final List<Color> gradient;

  const ClientAvatar({
    super.key,
    required this.name,
    this.size = 38,
    this.gradient = const [Color(0xFF667eea), Color(0xFF764ba2)],
  });

  static const _gradients = [
    [Color(0xFF667eea), Color(0xFF764ba2)],
    [Color(0xFFf093fb), Color(0xFFf5576c)],
    [Color(0xFF4facfe), Color(0xFF00f2fe)],
    [Color(0xFF43e97b), Color(0xFF38f9d7)],
    [Color(0xFFfa709a), Color(0xFFfee140)],
    [Color(0xFFa18cd1), Color(0xFFfbc2eb)],
  ];

  static List<Color> gradientFor(String name) {
    final idx = name.isEmpty ? 0 : name.codeUnitAt(0) % _gradients.length;
    return _gradients[idx];
  }

  @override
  Widget build(BuildContext context) {
    final grad = gradient.length == 2 ? gradient : gradientFor(name);
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: grad, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: AppTextStyles.bodyMed.copyWith(
            color: Colors.white, fontSize: size * .38, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// INFO TILE  (client detail page)
// ══════════════════════════════════════════════
class InfoTile extends StatelessWidget {
  final String label, value;
  const InfoTile({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.bg,
      borderRadius: BorderRadius.circular(kRadiusSm),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(),
          style: AppTextStyles.small.copyWith(
              fontSize: 10.5, letterSpacing: .5, fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      Text(value, style: AppTextStyles.bodyMed),
    ]),
  );
}

// ══════════════════════════════════════════════
// STAT CARD  (dashboard)
// ══════════════════════════════════════════════
class StatCard extends StatelessWidget {
  final String value;
  final String label;

  final String? emoji;
  final String? change;
  final bool? up;

  final Color valueColor;
  final Color iconBg;
  final double progress;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.valueColor,
    required this.iconBg,
    required this.progress,
    this.emoji,
    this.change,
    this.up,
  });

  @override
  Widget build(BuildContext context) => CrmCard(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// ICON BOX
          if (emoji != null)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(emoji!, style: const TextStyle(fontSize: 20)),
            ),

          if (emoji != null) const SizedBox(height: 14),

          /// VALUE
          Text(
            value,
            style: AppTextStyles.display.copyWith(
              fontSize: 28,
              color: valueColor,
            ),
          ),

          const SizedBox(height: 2),

          /// LABEL
          Text(label, style: AppTextStyles.small),

          /// CHANGE TEXT
          if (change != null) ...[
            const SizedBox(height: 6),
            Text(
              change!,
              style: AppTextStyles.small.copyWith(
                color: (up ?? true) ? AppColors.accent : AppColors.danger,
                fontWeight: FontWeight.w700,
                fontSize: 11.5,
              ),
            ),
          ],

          const SizedBox(height: 6),

          /// PROGRESS
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(valueColor),
            ),
          ),
        ],
      ),
    ),
  );
}