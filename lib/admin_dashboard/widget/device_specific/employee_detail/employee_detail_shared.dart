import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  const SectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool copyable;
  final Widget? valueWidget;
  final int maxLines;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.copyable = false,
    this.valueWidget,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF9CA3AF)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280))),
                const SizedBox(height: 4),
                valueWidget ??
                    Text(
                      value,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A)),
                      maxLines: maxLines,
                      overflow: TextOverflow.ellipsis,
                    ),
              ],
            ),
          ),
          if (copyable)
            IconButton(
              icon: const Icon(Icons.copy_outlined, size: 16),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
              },
            )
        ],
      ),
    );
  }
}

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: Color(0xFFE5E7EB));
  }
}

/// Helpers

String formatDate(String? date) {
  if (date == null || date.isEmpty) return '-';
  try {
    final dt = DateTime.parse(date);
    return DateFormat('dd MMM, yyyy').format(dt);
  } catch (_) {
    return date;
  }
}

String formatJoinDate(String? date) {
  if (date == null || date.isEmpty) return '-';
  try {
    final dt = DateTime.parse(date);
    final now = DateTime.now();
    final diff = now.difference(dt);
    final years = diff.inDays ~/ 365;
    if (years > 0) return '$years yr${years > 1 ? 's' : ''}';
    final months = diff.inDays ~/ 30;
    if (months > 0) return '$months mo${months > 1 ? 's' : ''}';
    return '${diff.inDays} days';
  } catch (_) {
    return date;
  }
}
