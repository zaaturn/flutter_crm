import 'dart:js_interop';

@JS('removeSplashFromWeb')
external void _removeSplashFromWeb();

void removeWebHtmlSplashOverlay() {
  try {
    _removeSplashFromWeb();
  } catch (_) {}
}
