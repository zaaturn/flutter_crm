import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/dashboards/presentations/bloc/audience_bloc.dart';
import 'package:my_app/dashboards/presentations/bloc/audience_event.dart';
import 'package:my_app/dashboards/presentations/bloc/audience_state.dart';

class AudienceItemList extends StatelessWidget {
  const AudienceItemList({super.key});

  bool? _selectAllValue(AudienceLoaded state) {
    if (state.items.isEmpty) return false;
    final sel = state.selectionFor(state.activeTab);
    var selectedCount = 0;
    for (final item in state.items) {
      if (sel.contains(item)) selectedCount++;
    }
    if (selectedCount == 0) return false;
    if (selectedCount == state.items.length) return true;
    return null; // indeterminate
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudienceBloc, AudienceState>(
      builder: (context, state) {
        if (state is AudienceLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(
                color: Color(0xFF00BCD4),
                strokeWidth: 2,
              ),
            ),
          );
        }

        if (state is AudienceError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: Colors.red[300], size: 28),
                  const SizedBox(height: 8),
                  const Text(
                    "Failed to load. Tap to retry.",
                    style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.read<AudienceBloc>().add(AudienceTabChanged(state.activeTab)),
                    child: const Text("Retry", style: TextStyle(color: Color(0xFF00BCD4))),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is AudienceLoaded) {
          if (state.items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off, color: Color(0xFFE5E7EB), size: 28),
                    SizedBox(height: 8),
                    Text("No results found.", style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
                  ],
                ),
              ),
            );
          }

          final selectAllValue = _selectAllValue(state);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                child: InkWell(
                  onTap: () {
                    final next = !(selectAllValue ?? false);
                    context
                        .read<AudienceBloc>()
                        .add(AudienceSelectAllToggled(select: next));
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            tristate: true,
                            value: selectAllValue,
                            onChanged: (v) => context
                                .read<AudienceBloc>()
                                .add(AudienceSelectAllToggled(select: v ?? true)),
                            activeColor: const Color(0xFF00BCD4),
                            side: const BorderSide(
                              color: Color(0xFFD1D5DB),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Select all',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                        Text(
                          '${state.selectionFor(state.activeTab).length} selected',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  // Fixed extent keeps scrolling smooth for big lists (1000+).
                  itemExtent: 44,
                  cacheExtent: 900,
                  itemCount: state.items.length,
                  itemBuilder: (_, i) {
                    final item = state.items[i];
                    final checked =
                        state.selectionFor(state.activeTab).contains(item);
                    return _CheckItem(
                      label: item,
                      checked: checked,
                      onTap: () => context
                          .read<AudienceBloc>()
                          .add(AudienceItemToggled(item)),
                    );
                  },
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _CheckItem extends StatelessWidget {
  final String label;
  final bool checked;
  final VoidCallback onTap;

  const _CheckItem({
    required this.label,
    required this.checked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: checked,
                onChanged: (_) => onTap(),
                activeColor: const Color(0xFF00BCD4),
                side: const BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF111827),
                  fontWeight: checked ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}