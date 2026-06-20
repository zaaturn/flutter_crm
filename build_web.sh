#!/usr/bin/env bash
# Web build for Firebase / Hostinger — full icon font, FCM-compatible (no Flutter PWA worker).
set -euo pipefail
cd "$(dirname "$0")"
flutter build web --release --pwa-strategy=none --no-tree-shake-icons
echo ""
echo "OK: deploy build/web to Firebase or Hostinger (HTTPS required for push)."
