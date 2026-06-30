import 'package:flutter/material.dart';
import 'package:my_app/event_management/features/dashboard/shared/dashboard_ui_theme.dart';
import 'package:my_app/event_management/shared/themes/app_theme.dart';

import 'event_create_constants.dart';

/// Composer top bar: back, title, primary action (Save / Update).
class EventCreateAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSaving;
  final VoidCallback onSave;
  final String saveButtonLabel;

  const EventCreateAppBar({
    super.key,
    required this.isSaving,
    required this.onSave,
    this.saveButtonLabel = 'Save',
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: DashboardUiTheme.pageBackground,
      foregroundColor: AppTheme.textPrimary,
      centerTitle: false,
      title: Text(
        saveButtonLabel == 'Save'
            ? EventCreateLayout.brandTitle
            : 'Edit Event',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: DashboardUiTheme.textDark,
            ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
          child: FilledButton(
            onPressed: isSaving ? null : onSave,
            style: FilledButton.styleFrom(
              backgroundColor: DashboardUiTheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
                    saveButtonLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
