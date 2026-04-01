import 'package:flutter/material.dart';

/// Pops [routeContext] then shows a snackbar on the still-mounted navigator
/// (avoids using a disposed route context; snackbar appears on the screen below).
void popRouteThenShowSnackBar(
  BuildContext routeContext,
  SnackBar snackBar,
) {
  final nav = Navigator.of(routeContext);
  nav.pop();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!nav.mounted) return;
    ScaffoldMessenger.maybeOf(nav.context)?.showSnackBar(snackBar);
  });
}
