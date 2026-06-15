# PowerShell helper to run TowerDef in Chrome on Windows for fast iteration
# Usage: .\run_windows_chrome.ps1
param()

Write-Host "Running TowerDef in Chrome (web)"
flutter pub get
flutter run -d chrome
