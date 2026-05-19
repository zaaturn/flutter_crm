@echo off
REM Flutter's default PWA service worker fights with Firebase Cloud Messaging at scope "/".
REM Build WITHOUT Flutter's worker so firebase-messaging-sw.js can receive push (like WhatsApp Web).
cd /d "%~dp0"
flutter build web --release --pwa-strategy=none
if errorlevel 1 exit /b 1
echo.
echo OK: deploy build\web to hosting. Chrome push requires HTTPS (or localhost).
