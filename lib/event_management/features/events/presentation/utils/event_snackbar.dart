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
  if (!routeContext.mounted) return;

  // Important: defer the pop until after the current frame.
  // Popping while the keyboard/focus/inherited widgets are mid-update can trigger:
  // `_dependents.isEmpty` / `attached` / "dirty widget wrong build scope".
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!routeContext.mounted) return;
    final nav = Navigator.of(routeContext);
    if (nav.canPop()) nav.pop();

    rootScaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  });
}
