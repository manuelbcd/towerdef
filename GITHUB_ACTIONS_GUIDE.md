# GitHub Actions CI Reference

This project includes a multi-platform CI/CD pipeline configured in `.github/workflows/ci.yml`.

## Quick Start

1. **Push your code to GitHub**
   ```bash
   git push origin main
   ```

2. **Check CI status**
   - Go to your repository on GitHub
   - Click the **Actions** tab
   - View the latest workflow run

3. **Download build artifacts**
   - After a successful run, scroll to **Artifacts** section
   - Download platform-specific builds (web, APK, desktop apps)

## What CI Tests

✅ **Dart Analysis** — Code quality checks  
✅ **Unit Tests** — `flutter test` runs on all platforms  
✅ **Code Formatting** — `dart format` validation  
✅ **Builds** — Web, Android APK, macOS, Windows  

## Platform Coverage

| Platform | Runner | Output |
|----------|--------|--------|
| **Web** | Ubuntu, macOS, Windows | `build/web/` |
| **Android APK** | Ubuntu | `build/app/outputs/apk/release/app-release.apk` |
| **macOS app** | macOS | `build/macos/Build/Products/Release/towerdef.app` |
| **Windows app** | Windows | `build/windows/runner/Release/towerdef.exe` |

## Running CI Locally

Before pushing, run the same checks locally:

```bash
flutter pub get
flutter analyze           # Code quality
flutter test              # Unit tests
dart format --set-exit-if-changed lib test  # Format check
flutter build web --release  # Web build
```

For platform-specific builds:
```bash
flutter build macos --release    # macOS
flutter build windows --release  # Windows
flutter build apk --release      # Android
flutter build linux --release    # Linux
```

## Triggered On

- **Push** to `main` or `develop` branches
- **Pull request** against `main` or `develop`

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Tests fail locally | Run `flutter test -v` and fix failing tests |
| Format issues | Run `dart format lib test -i` to auto-fix |
| Build fails | Check platform prerequisites (Xcode, Visual Studio, etc.) |
| CI still failing after fix | Push again; CI re-runs automatically |

## Viewing Logs

1. Go to **Actions** tab
2. Click the failed workflow run
3. Click the failed job (e.g., "Test & Build on ubuntu-latest")
4. Expand the failed step to see error details

## Customizing Workflow

Edit `.github/workflows/ci.yml` to:
- Add steps (e.g., APK signing, deployment)
- Change Flutter version
- Add/remove platforms
- Configure notifications

See [GitHub Actions documentation](https://docs.github.com/en/actions) for details.
