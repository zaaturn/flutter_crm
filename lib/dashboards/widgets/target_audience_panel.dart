import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/dashboards/widgets/audience_tab.dart';
import 'package:my_app/dashboards/presentations/bloc/audience_bloc.dart';
import 'package:my_app/dashboards/presentations/bloc/audience_event.dart';
import 'package:my_app/dashboards/presentations/bloc/audience_state.dart';
import 'audience_tab_selector.dart';
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
      width: 280,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Target Audience",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  panelSubtitle,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          BlocBuilder<AudienceBloc, AudienceState>(
            builder: (context, state) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: AudienceTabSelector(activeTab: state.activeTab),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _SearchField(),
          ),
          const SizedBox(height: 6),
          const Expanded(child: AudienceItemList()),
          const _PanelFooter(),
        ],
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
        onChanged: (v) => context.read<AudienceBloc>().add(AudienceSearchChanged(v)),
        style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
        decoration: InputDecoration(
          hintText: "Search selection...",
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 17),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _PanelFooter extends StatelessWidget {
  const _PanelFooter();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudienceBloc, AudienceState>(
      builder: (context, state) {
        final count = state.selected.length;
        final tabLabel = state.activeTab.selectionLabel;
        final label = count == 0 ? "None" : "$count $tabLabel${count > 1 ? "s" : ""}";
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 13),
                  children: [
                    const TextSpan(text: "Selected: ", style: TextStyle(color: Color(0xFF6B7280))),
                    TextSpan(text: label, style: const TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              if (count > 0)
                GestureDetector(
                  onTap: () => context.read<AudienceBloc>().add(AudienceSelectionCleared()),
                  child: const Text("Clear All", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF00BCD4))),
                ),
            ],
          ),
        );
      },
    );
  }
}