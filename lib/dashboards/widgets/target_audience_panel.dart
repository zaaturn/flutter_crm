import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/dashboards/widgets/audience_tab.dart';
import 'package:my_app/dashboards/presentations/bloc/audience_bloc.dart';
import 'package:my_app/dashboards/presentations/bloc/audience_event.dart';
import 'package:my_app/dashboards/presentations/bloc/audience_state.dart';
import 'audience_item_list.dart';

class TargetAudiencePanel extends StatelessWidget {
  final String panelSubtitle;

  const TargetAudiencePanel({
    super.key,
    this.panelSubtitle = "Choose who should see this item",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.60),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF8A79E5), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 22,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Expanded(
                    child: Text(
                      "Target Audience",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  Icon(Icons.filter_list, color: Color(0xFF604EB8), size: 18),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                panelSubtitle,
                style:
                    const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 16),
              _PickerRow(tab: AudienceTab.byDepartment, label: 'Department'),
              const SizedBox(height: 12),
              _PickerRow(tab: AudienceTab.byDesignation, label: 'Designation'),
              const SizedBox(height: 12),
              _PickerRow(tab: AudienceTab.specificUsers, label: 'Users'),
              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: 10),
              const _PanelFooter(sidebar: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  final AudienceTab tab;
  final String label;
  const _PickerRow({required this.tab, required this.label});

  static int _countFor(AudienceState state, AudienceTab t) {
    return switch (t) {
      AudienceTab.byDepartment => state.selectedDepartments.length,
      AudienceTab.byDesignation => state.selectedDesignations.length,
      AudienceTab.specificUsers => state.selectedUsers.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudienceBloc, AudienceState>(
      builder: (context, state) {
        final selectedCount = _countFor(state, tab);
        final display =
            selectedCount == 0 ? 'All' : '$selectedCount selected';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Color(0xFF6B7280),
                letterSpacing: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                context.read<AudienceBloc>().add(AudienceTabChanged(tab));
                await showDialog<void>(
                  context: context,
                  barrierColor: Colors.black.withValues(alpha: 0.38),
                  builder: (dlgCtx) => _GlassAudiencePickerDialog(
                    title: 'Select $label',
                    pickTab: tab,
                  ),
                );
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        tab == AudienceTab.specificUsers
                            ? '$display Users'
                            : '$display ${label}s',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    const Icon(Icons.expand_more, color: Color(0xFF6B7280)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GlassAudiencePickerDialog extends StatelessWidget {
  final String title;
  final AudienceTab pickTab;

  const _GlassAudiencePickerDialog({
    required this.title,
    required this.pickTab,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 520,
            height: 520,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.45),
                width: 1.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.55),
                  Colors.white.withValues(alpha: 0.28),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF604EB8).withValues(alpha: 0.12),
                  blurRadius: 32,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 8, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                            color: Color(0xFF111827),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        color: const Color(0xFF64748B),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: _SearchField(),
                ),
                const SizedBox(height: 8),
                const Expanded(child: AudienceItemList()),
                _PanelFooter(sidebar: false, forTab: pickTab),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatefulWidget {
  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AudienceBloc, AudienceState>(
      listenWhen: (prev, curr) => prev.activeTab != curr.activeTab,
      listener: (_, __) => _ctrl.clear(),
      child: TextField(
        controller: _ctrl,
        onChanged: (v) =>
            context.read<AudienceBloc>().add(AudienceSearchChanged(v)),
        style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
        decoration: InputDecoration(
          hintText: "Search selection...",
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
          prefixIcon:
              const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 17),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.72),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF8A79E5), width: 2),
          ),
        ),
      ),
    );
  }
}

class _PanelFooter extends StatelessWidget {
  /// Summary of all three filters (right-hand sidebar).
  final bool sidebar;

  /// When [sidebar] is false, selections shown are for this tab only (modal).
  final AudienceTab? forTab;

  const _PanelFooter({required this.sidebar, this.forTab});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudienceBloc, AudienceState>(
      builder: (context, state) {
        final String label;
        final int count;
        if (sidebar) {
          final d = state.selectedDepartments.length;
          final z = state.selectedDesignations.length;
          final u = state.selectedUsers.length;
          count = d + z + u;
          if (count == 0) {
            label = 'None';
          } else {
            final parts = <String>[];
            if (d > 0) parts.add('$d dept${d == 1 ? '' : 's'}');
            if (z > 0) parts.add('$z desig${z == 1 ? '' : 's'}');
            if (u > 0) parts.add('$u user${u == 1 ? '' : 's'}');
            label = parts.join(' · ');
          }
        } else {
          final tab = forTab ?? state.activeTab;
          final sel = state.selectionFor(tab);
          count = sel.length;
          final tabLabel = tab.selectionLabel;
          label = count == 0
              ? 'None'
              : '$count $tabLabel${count > 1 ? 's' : ''}';
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 13),
                    children: [
                      const TextSpan(
                        text: "Selected: ",
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                      TextSpan(
                        text: label,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (count > 0)
                GestureDetector(
                  onTap: () => context.read<AudienceBloc>().add(
                        sidebar
                            ? AudienceSelectionCleared()
                            : AudienceSelectionCleared(onlyTab: forTab),
                      ),
                  child: Text(
                    sidebar ? "Clear all" : "Clear",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF604EB8),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
