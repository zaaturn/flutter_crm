import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/event_management/core/utils/indian_time.dart';
import 'package:my_app/event_management/features/events/domain/entities/event.dart';

class ZaaturnComposerUI {
  static const Color background = Color(0xFFFAF3E0);
  static const Color terracotta = Color(0xFFC05E41);
  static const Color card = Color(0xFFEADBC8);
  static const Color field = Color(0xFFF5EDE0);
  static const Color textDark = Color(0xFF3E2723);
  static const Color textMuted = Color(0xFF8D6E63);
}

class EventComposerMobileHeader extends StatelessWidget {
  final String title;
  final String saveLabel;
  final bool isSaving;
  final VoidCallback onSave;

  const EventComposerMobileHeader({
    super.key,
    required this.title,
    required this.saveLabel,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: ZaaturnComposerUI.textDark,
              size: 20,
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: ZaaturnComposerUI.textDark,
              ),
            ),
          ),
          FilledButton(
            onPressed: isSaving ? null : onSave,
            style: FilledButton.styleFrom(
              backgroundColor: ZaaturnComposerUI.terracotta,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    saveLabel,
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w900),
                  ),
          ),
        ],
      ),
    );
  }
}

class EventComposerSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const EventComposerSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ZaaturnComposerUI.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: ZaaturnComposerUI.terracotta),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: ZaaturnComposerUI.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class EventComposerFieldLabel extends StatelessWidget {
  final String label;

  const EventComposerFieldLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: ZaaturnComposerUI.textMuted,
        ),
      ),
    );
  }
}

class EventComposerTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const EventComposerTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.manrope(
        fontWeight: FontWeight.w700,
        color: ZaaturnComposerUI.textDark,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.manrope(
          color: ZaaturnComposerUI.textMuted.withValues(alpha: 0.7),
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: ZaaturnComposerUI.field,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

class EventComposerScheduleRow extends StatelessWidget {
  final String label;
  final DateTime value;
  final bool allDay;
  final VoidCallback onTap;

  const EventComposerScheduleRow({
    super.key,
    required this.label,
    required this.value,
    required this.allDay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = allDay
        ? IndianTime.formatDateHeader(value)
        : IndianTime.formatDayAndTime(value);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EventComposerFieldLabel(label),
                  Text(
                    text,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: ZaaturnComposerUI.textDark,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit_calendar_rounded,
              color: ZaaturnComposerUI.terracotta.withValues(alpha: 0.85),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class EventComposerReminderChips extends StatelessWidget {
  final List<int> selected;
  final ValueChanged<List<int>> onChanged;

  const EventComposerReminderChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _options = [
    (label: '10 min before', value: 10),
    (label: '30 min before', value: 30),
    (label: '1 hour before', value: 60),
    (label: '1 day before', value: 1440),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _options.map((opt) {
        final isSel = selected.contains(opt.value);
        return FilterChip(
          label: Text(opt.label),
          selected: isSel,
          showCheckmark: true,
          selectedColor: ZaaturnComposerUI.terracotta,
          backgroundColor: Colors.white.withValues(alpha: 0.7),
          labelStyle: GoogleFonts.manrope(
            fontWeight: FontWeight.w800,
            color: isSel ? Colors.white : ZaaturnComposerUI.textDark,
            fontSize: 12,
          ),
          checkmarkColor: Colors.white,
          side: BorderSide(
            color: isSel
                ? ZaaturnComposerUI.terracotta
                : ZaaturnComposerUI.textMuted.withValues(alpha: 0.25),
          ),
          onSelected: (_) {
            final next = List<int>.from(selected);
            if (isSel) {
              next.remove(opt.value);
            } else {
              next.add(opt.value);
            }
            onChanged(next);
          },
        );
      }).toList(),
    );
  }
}

String recurrenceLabel(RecurrenceRule rule) {
  if (rule == RecurrenceRule.none) return 'Never';
  return rule.name[0].toUpperCase() + rule.name.substring(1);
}
