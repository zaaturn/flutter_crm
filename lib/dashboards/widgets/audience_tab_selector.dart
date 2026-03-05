import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/dashboards/widgets/audience_tab.dart';
import 'package:my_app/dashboards/presentations/bloc/audience_bloc.dart';
import 'package:my_app/dashboards/presentations/bloc/audience_event.dart';
import 'package:my_app/dashboards/presentations/bloc/audience_state.dart';
import 'package:my_app/dashboards/widgets/app_color.dart';
class AudienceTabSelector extends StatelessWidget {
  final AudienceTab activeTab;

  const AudienceTabSelector({super.key, required this.activeTab});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pageBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        children: AudienceTab.values
            .map((tab) => _TabTile(
          tab: tab,
          isActive: tab == activeTab,
          onTap: () => context
              .read<AudienceBloc>()
              .add(AudienceTabChanged(tab)),
        ))
            .toList(),
      ),
    );
  }
}

class _TabTile extends StatelessWidget {
  final AudienceTab tab;
  final bool isActive;
  final VoidCallback onTap;

  const _TabTile({
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.cyanLight : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          children: [
            Icon(
              tab.icon,
              size: 15,
              color: isActive
                  ? AppColors.cyan
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              tab.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive
                    ? AppColors.cyan
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}