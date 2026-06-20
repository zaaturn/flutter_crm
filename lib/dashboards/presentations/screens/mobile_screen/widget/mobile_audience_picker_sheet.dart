import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/dashboards/presentations/bloc/audience_bloc.dart';
import 'package:my_app/dashboards/presentations/bloc/audience_event.dart';
import 'package:my_app/dashboards/presentations/bloc/audience_state.dart';
import 'package:my_app/dashboards/widgets/audience_item_list.dart';
import 'package:my_app/dashboards/widgets/audience_tab.dart';

class MobileAudiencePickers extends StatelessWidget {
  const MobileAudiencePickers({super.key});

  static const Color _boxFill = Color(0xFFF5E6DA);
  static const Color _accentColor = Color(0xFFB14D1E);
  static const Color _textMain = Color(0xFF1A1C1E);

  static int _countFor(AudienceState s, AudienceTab t) => switch (t) {
    AudienceTab.byDepartment => s.selectedDepartments.length,
    AudienceTab.byDesignation => s.selectedDesignations.length,
    AudienceTab.specificUsers => s.selectedUsers.length,
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudienceBloc, AudienceState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PickerRow(
              label: 'Select Department',
              tab: AudienceTab.byDepartment,
              count: _countFor(state, AudienceTab.byDepartment),
              fillColor: _boxFill,
              accentColor: _accentColor,
            ),
            const SizedBox(height: 12),
            _PickerRow(
              label: 'Select Designation',
              tab: AudienceTab.byDesignation,
              count: _countFor(state, AudienceTab.byDesignation),
              fillColor: _boxFill,
              accentColor: _accentColor,
            ),
            const SizedBox(height: 12),
            _PickerRow(
              label: 'Select Users',
              tab: AudienceTab.specificUsers,
              count: _countFor(state, AudienceTab.specificUsers),
              fillColor: _boxFill,
              accentColor: _accentColor,
            ),
          ],
        );
      },
    );
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.label,
    required this.tab,
    required this.count,
    required this.fillColor,
    required this.accentColor,
  });

  final String label;
  final AudienceTab tab;
  final int count;
  final Color fillColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final display = count == 0 ? label : '$label ($count)';
    return InkWell(
      onTap: () async {
        context.read<AudienceBloc>().add(AudienceTabChanged(tab));
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _AudiencePickerSheet(tab: tab, title: label),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accentColor.withOpacity(0.1), width: 1.2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                display,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1C1E),
                ),
              ),
            ),
            Icon(Icons.expand_more_rounded, color: accentColor.withOpacity(0.6)),
          ],
        ),
      ),
    );
  }
}

class _AudiencePickerSheet extends StatefulWidget {
  const _AudiencePickerSheet({required this.tab, required this.title});

  final AudienceTab tab;
  final String title;

  @override
  State<_AudiencePickerSheet> createState() => _AudiencePickerSheetState();
}

class _AudiencePickerSheetState extends State<_AudiencePickerSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.88;
    return SafeArea(
      top: false,
      child: SizedBox(
        height: sheetHeight,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFEF7F1),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.05))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1C1E),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context
                          .read<AudienceBloc>()
                          .add(AudienceSelectionCleared(onlyTab: widget.tab));
                    },
                    child: Text(
                      'Clear',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFB14D1E),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: const Color(0xFF74777F),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: TextField(
                controller: _ctrl,
                onChanged: (v) =>
                    context.read<AudienceBloc>().add(AudienceSearchChanged(v)),
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFB14D1E)),
                  filled: true,
                  fillColor: const Color(0xFFF5E6DA),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: const Color(0xFFB14D1E).withOpacity(0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFB14D1E), width: 1.2),
                  ),
                ),
              ),
            ),
            const Expanded(child: AudienceItemList()),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottom),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C56D0),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Done',
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}