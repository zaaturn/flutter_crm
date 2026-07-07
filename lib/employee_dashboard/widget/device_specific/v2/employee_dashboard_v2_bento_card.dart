import 'package:flutter/material.dart';
import 'employee_dashboard_v2_theme.dart';

class EmployeeDashboardV2BentoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? background;

  const EmployeeDashboardV2BentoCard({
    super.key,
    required this.child,
    this.padding,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(EmployeeDashboardV2Theme.cardPadding),
      decoration: EmployeeDashboardV2Theme.cardDecoration(background: background),
      child: child,
    );
  }
}
