import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/pdf_design_option.dart';
import '../../../theme/billing_theme.dart';
import '../../../utils/pdf_design_mapper.dart';

class PdfDesignGrid extends StatelessWidget {
  final List<PdfDesignOption> options;
  final PdfDesignOption? selected;
  final ValueChanged<PdfDesignOption> onSelect;

  const PdfDesignGrid({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return Text('No designs available', style: BillingTheme.body());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 420;
        final crossAxisCount = wide ? 2 : 1;
        final childAspectRatio = wide ? 1.6 : 3.2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: options.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (_, i) {
            final d = options[i];
            final isSelected = selected?.id == d.id;
            return _DesignTile(
              design: d,
              selected: isSelected,
              onTap: () => onSelect(d),
            );
          },
        );
      },
    );
  }
}

class _DesignTile extends StatelessWidget {
  final PdfDesignOption design;
  final bool selected;
  final VoidCallback onTap;

  const _DesignTile({
    required this.design,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = _designTheme(design);
    final borderColor = selected ? theme.accent : BillingTheme.border;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            gradient: theme.gradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: selected ? 1.8 : 1),
            boxShadow: [
              BoxShadow(
                color: theme.accent.withValues(alpha: selected ? 0.22 : 0.10),
                blurRadius: selected ? 18 : 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: theme.pillBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.accent.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: theme.accent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  (design.label.isNotEmpty ? design.label : design.id),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: theme.textColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: selected ? theme.accent : theme.pillBg,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: theme.accent.withValues(alpha: selected ? 0.0 : 0.18),
                  ),
                ),
                child: Text(
                  selected ? 'Selected' : 'Pick',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: selected ? Colors.white : theme.accent,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _DesignTheme _designTheme(PdfDesignOption design) {
    final id = canonicalPdfDesignId(design.id);
    switch (id) {
      case 'MINIMAL':
      case 'MINIMALIST':
      case 'MINIMALISTE':
        // Minimal: clean full white.
        return const _DesignTheme(
          accent: Color(0xFF111827),
          textColor: Color(0xFF0F172A),
          pillBg: Color(0xFFFFFFFF),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFF8FAFC),
            ],
          ),
        );
      case 'DARK_LUXURY':
        // Deep indigo + charcoal (luxury).
        return _DesignTheme(
          accent: const Color(0xFF4F46E5),
          textColor: const Color(0xFFF8FAFC),
          pillBg: const Color(0xFF111827),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF111827),
              Color(0xFF0B1020),
            ],
          ),
        );
      case 'CLASSIC_GOLD':
        // Warm gold + cream.
        return _DesignTheme(
          accent: const Color(0xFFB45309),
          textColor: const Color(0xFF3B2F0B),
          pillBg: const Color(0xFFFFF7ED),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFBEB),
              Color(0xFFFFF7ED),
            ],
          ),
        );
      case 'MODERN':
      case 'INVOICE_MODERN':
        // Modern: white + mint/green mix.
        return const _DesignTheme(
          accent: Color(0xFF16A34A),
          textColor: Color(0xFF064E3B),
          pillBg: Color(0xFFECFDF5),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFECFDF5),
            ],
          ),
        );
      case 'CLASSIC':
      case 'INVOICE_CLASSIC':
        // Classic: light black / graphite.
        return const _DesignTheme(
          accent: Color(0xFF111827),
          textColor: Color(0xFF0B1220),
          pillBg: Color(0xFFF3F4F6),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF3F4F6),
              Color(0xFFE5E7EB),
            ],
          ),
        );
      default:
        // Generic light purple SaaS.
        return _DesignTheme(
          accent: BillingTheme.purple,
          textColor: BillingTheme.textPrimary,
          pillBg: BillingTheme.purpleLight,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              BillingTheme.purpleLight,
              BillingTheme.scaffoldBg,
            ],
          ),
        );
    }
  }
}

class _DesignTheme {
  final Color accent;
  final Color textColor;
  final Color pillBg;
  final LinearGradient gradient;

  const _DesignTheme({
    required this.accent,
    required this.textColor,
    required this.pillBg,
    required this.gradient,
  });
}

