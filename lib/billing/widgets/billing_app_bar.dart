import 'package:flutter/material.dart';
import '../theme/billing_theme.dart';

PreferredSizeWidget billingAppBar({
  required String title,
  required VoidCallback onBack,
  List<Widget>? actions,
}) {
  return AppBar(
    backgroundColor: BillingTheme.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_rounded, color: BillingTheme.textPrimary),
      onPressed: onBack,
      tooltip: 'Back',
    ),
    title: Text(title, style: BillingTheme.titleAppBar()),
    centerTitle: false,
    actions: actions,
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(height: 1, color: BillingTheme.border),
    ),
  );
}
