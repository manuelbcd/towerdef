# PowerShell helper to run TowerDef on Windows
# Usage: .\run_windows.ps1
param()

Write-Host "Running TowerDef on Windows (requires flutter in PATH)"
flutter pub get
flutter run -d windows
