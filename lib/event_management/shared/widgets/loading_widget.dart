import 'package:flutter/material.dart';
import 'package:my_app/event_management/shared/themes/app_theme.dart';

/// Centered spinner with an optional label.
class LoadingWidget extends StatelessWidget {
  final String? message;
  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppTheme.primaryBlue),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ],
        ),
      );
}