import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../bloc/payroll_dashboard_bloc.dart';
import '../bloc/payroll_dashboard_event.dart';
import '../bloc/payroll_dashboard_state.dart';


class WorkspaceTheme {
  static const Color primaryPurple = Color(0xFF6F34DC);
  static const Color cardSurface = Colors.white;
  static const Color borderSubtle = Color(0xFFE8E9F1);
  static const Color textMain = Color(0xFF222329);
  static const Color textMuted = Color(0xFF6A6B74);
  static const Color inputBg = Color(0xFFF8F9FE);
}

class PayrollFilterSection extends StatefulWidget {
  const PayrollFilterSection({super.key});

  @override
  State<PayrollFilterSection> createState() => _PayrollFilterSectionState();
}

class _PayrollFilterSectionState extends State<PayrollFilterSection> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PayrollDashboardBloc, PayrollDashboardState>(
      builder: (context, state) {
        return Container(

          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: WorkspaceTheme.cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: WorkspaceTheme.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FILTER BY PERIOD',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: WorkspaceTheme.textMuted,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [

                  _StyledDropdown<int>(
                    value: state.monthIndex.clamp(1, 12),
                    items: List.generate(12, (i) => i + 1),
                    labelBuilder: (m) => DateFormat('MMMM').format(DateTime(2024, m)),
                    onChanged: (m) => context
                        .read<PayrollDashboardBloc>()
                        .add(PayrollDashboardMonthChanged(m!)),
                  ),


                  _StyledDropdown<int>(
                    value: state.year,
                    items: List.generate(5, (i) => DateTime.now().year - i),
                    labelBuilder: (y) => '$y',
                    onChanged: (y) => context
                        .read<PayrollDashboardBloc>()
                        .add(PayrollDashboardYearChanged(y!)),
                  ),


                  Container(
                    width: 320,
                    decoration: BoxDecoration(
                      color: WorkspaceTheme.inputBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: WorkspaceTheme.borderSubtle),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      cursorColor: WorkspaceTheme.primaryPurple,
                      onSubmitted: (v) => context
                          .read<PayrollDashboardBloc>()
                          .add(PayrollDashboardSearchSubmitted(v.trim())),
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: WorkspaceTheme.textMain
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search employee name...',
                        hintStyle: GoogleFonts.inter(color: WorkspaceTheme.textMuted, fontWeight: FontWeight.w400),
                        prefixIcon: const Icon(Icons.search_rounded,
                            size: 20, color: WorkspaceTheme.primaryPurple),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),


                  ElevatedButton(
                    onPressed: () => context.read<PayrollDashboardBloc>().add(
                      PayrollDashboardSearchSubmitted(_searchCtrl.text.trim()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WorkspaceTheme.primaryPurple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Apply Filter',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StyledDropdown<T> extends StatelessWidget {
  const _StyledDropdown({
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: WorkspaceTheme.inputBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WorkspaceTheme.borderSubtle),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: WorkspaceTheme.primaryPurple, size: 20),
          dropdownColor: WorkspaceTheme.cardSurface,
          borderRadius: BorderRadius.circular(12),
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: WorkspaceTheme.textMain,
          ),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(labelBuilder(item)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}