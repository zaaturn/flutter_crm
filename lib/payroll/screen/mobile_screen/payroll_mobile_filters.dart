import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../bloc/payroll_dashboard_bloc.dart';
import '../../bloc/payroll_dashboard_event.dart';
import '../../bloc/payroll_dashboard_state.dart';
import '../../models/payroll_records_paid_filter.dart';

class ZaaturnUI {
  static const Color background = Color(0xFFFAF3E0); // Light Cream
  static const Color cardColor = Color(0xFFEADBC8);   // Terracotta/Beige box
  static const Color fieldColor = Color(0xFFF2E6D6);  // Organic input fill
  static const Color accentOrange = Color(0xFFF3924C);
  static const Color darkTerracotta = Color(0xFFC05E41); // Dark Terracotta
  static const Color textMain = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF5D4037);
}

class PayrollMobileFiltersColumn extends StatefulWidget {
  const PayrollMobileFiltersColumn({super.key});

  @override
  State<PayrollMobileFiltersColumn> createState() => _PayrollMobileFiltersColumnState();
}

class _PayrollMobileFiltersColumnState extends State<PayrollMobileFiltersColumn> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  static BoxDecoration _cardDecoration() => BoxDecoration(
    color: ZaaturnUI.cardColor,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.03),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PayrollDashboardBloc, PayrollDashboardState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FILTER BY PERIOD',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: ZaaturnUI.darkTerracotta,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 22,
                        child: _LeaveDropdown<PayrollRecordsPaidFilter>(
                          value: state.recordsPaidFilter,
                          items: PayrollRecordsPaidFilter.values,
                          labelBuilder: (f) {
                            switch (f) {
                              case PayrollRecordsPaidFilter.all: return 'All';
                              case PayrollRecordsPaidFilter.paid: return 'Paid';
                              case PayrollRecordsPaidFilter.unpaid: return 'Unpaid';
                              case PayrollRecordsPaidFilter.unset: return 'Unset';
                            }
                          },
                          onChanged: (f) {
                            if (f == null) return;
                            context.read<PayrollDashboardBloc>().add(PayrollRecordsPaidFilterChanged(f));
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 18,
                        child: _LeaveDropdown<int>(
                          value: state.monthIndex.clamp(1, 12),
                          items: List.generate(12, (i) => i + 1),
                          labelBuilder: (m) => DateFormat('MMM').format(DateTime(2024, m)),
                          onChanged: (m) {
                            if (m == null) return;
                            context.read<PayrollDashboardBloc>().add(PayrollDashboardMonthChanged(m));
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 14,
                        child: _LeaveDropdown<int>(
                          value: state.year,
                          items: List.generate(5, (i) => DateTime.now().year - i),
                          labelBuilder: (y) => '$y',
                          onChanged: (y) {
                            if (y == null) return;
                            context.read<PayrollDashboardBloc>().add(PayrollDashboardYearChanged(y));
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SEARCH',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: ZaaturnUI.darkTerracotta,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _searchCtrl,
                    cursorColor: ZaaturnUI.darkTerracotta,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (v) => context.read<PayrollDashboardBloc>().add(
                      PayrollDashboardSearchSubmitted(v.trim()),
                    ),
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ZaaturnUI.textMain,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Employee name…',
                      hintStyle: GoogleFonts.manrope(
                        fontSize: 13,
                        color: ZaaturnUI.textMuted.withOpacity(0.5),
                        fontWeight: FontWeight.w500,
                      ),
                      filled: true,
                      fillColor: ZaaturnUI.fieldColor,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20, color: ZaaturnUI.darkTerracotta),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.arrow_forward_rounded, color: ZaaturnUI.darkTerracotta),
                        onPressed: () => context.read<PayrollDashboardBloc>().add(
                          PayrollDashboardSearchSubmitted(_searchCtrl.text.trim()),
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: ZaaturnUI.darkTerracotta, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LeaveDropdown<T> extends StatelessWidget {
  const _LeaveDropdown({
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  final T value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: ZaaturnUI.fieldColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          isExpanded: true,
          borderRadius: BorderRadius.circular(16),
          dropdownColor: ZaaturnUI.fieldColor,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: ZaaturnUI.darkTerracotta),
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: ZaaturnUI.textMain,
          ),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(labelBuilder(item), overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}