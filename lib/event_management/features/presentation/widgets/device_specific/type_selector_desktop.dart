import 'package:flutter/material.dart';
import 'package:my_app/event_management/core/constants/app_colors.dart';
import 'package:my_app/event_management/features/presentation/widgets/mock_data.dart';

class TypeSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const TypeSelector({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: EVENT_TYPES
          .map((type) => _TypeOption(
        type: type,
        isSelected: type == selected,
        onTap: () => onChanged(type),
      ))
          .toList(),
    );
  }
}

class _TypeOption extends StatefulWidget {
  final String type;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeOption({
    super.key,
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_TypeOption> createState() => _TypeOptionState();
}

class _TypeOptionState extends State<_TypeOption> {
  bool _isHovered = false; // Track hover state for desktop

  @override
  Widget build(BuildContext context) {
    final tc = EventTypeColor.of(widget.type);

    return Expanded(
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click, // Show hand cursor on desktop
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              // Background color changes on hover or selection
              color: widget.isSelected
                  ? tc.bg
                  : (_isHovered ? Colors.white : const Color(0xFFFAFBFC)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isSelected
                    ? tc.border
                    : (_isHovered ? AppColors.primary.withOpacity(0.4) : AppColors.border),
                width: 1.5,
              ),
              // Elevation effect on desktop
              boxShadow: [
                if (widget.isSelected || _isHovered)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Larger icons for desktop screens
                Text(
                    EVENT_TYPE_ICONS[widget.type] ?? '',
                    style: const TextStyle(fontSize: 22)
                ),
                const SizedBox(height: 8),
                Text(
                  EVENT_TYPE_LABELS[widget.type] ?? widget.type,
                  style: TextStyle(
                    fontSize: 13, // Slightly larger text
                    fontWeight: FontWeight.w600,
                    color: widget.isSelected ? tc.text : AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}