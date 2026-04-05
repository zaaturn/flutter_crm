import 'package:flutter/material.dart';
import 'package:my_app/core/scaffold_messenger_scope.dart';

/// Pops [routeContext] then shows a snackbar on the app root messenger.
///
/// Using [rootScaffoldMessengerKey] avoids `ScaffoldMessenger.maybeOf` returning
/// null after pop (common on web / nested navigators), which dropped snackbars.
void popRouteThenShowSnackBar(
  BuildContext routeContext,
  SnackBar snackBar,
) {
  final nav = Navigator.of(routeContext);
  if (!routeContext.mounted) return;
  nav.pop();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    rootScaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  });
}
