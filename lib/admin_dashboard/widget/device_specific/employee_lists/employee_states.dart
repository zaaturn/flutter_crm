import 'package:flutter/material.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/employee_lists/app_theme.dart';

// ── Error State ──────────────────────────────────────────────────────────────
class EmployeeErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const EmployeeErrorState({
    super.key,
    this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Large soft-red background icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.offline.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.offline,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Oops! Something went wrong",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textHeading,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message ??
                  "We couldn't load the employee list. Please check your connection and try again.",
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 160,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text("Try Again"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ── Empty State ──────────────────────────────────────────────────────────────
class EmployeeEmptyState extends StatelessWidget {
  final String? role;
  final VoidCallback onClear;

  const EmployeeEmptyState({
    super.key,
    this.role,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Daxarrow Purple themed empty icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_search_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              role != null ? 'No match for "$role"' : "No Employees Found",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textHeading,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              role != null
                  ? "Try adjusting your filters to find who you're looking for."
                  : "It looks like your employee directory is empty right now.",
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 24),
            if (role != null)
              TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.close, size: 16),
                label: const Text("Clear all filters"),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ),
    );
  }
}