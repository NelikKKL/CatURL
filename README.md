# 🐱 CatURL

A beautiful Material You Android app for creating and opening `.url` shortcut files.

<p align="center">
  <img src="assets/icon.png" width="120" alt="URL Opener icon">
</p>

## ✨ Features

- **Create `.url` files** — Windows-compatible internet shortcut format
- **Open `.url` files** — tap to open in browser, or choose "Open with…" for system dialog
- **Material You** — full dynamic color support (Android 12+), adapts to your wallpaper
- **File association** — appears in Android's "Open with" dialog for `.url` files
- **Search** — quickly find saved shortcuts
- **Persistent storage** — shortcuts survive app restarts

## 🚀 Getting Started

### Prerequisites

- Flutter 3.22+
- Android Studio / VS Code
- Android SDK with minSdkVersion 21

### Run locally

```bash
flutter pub get
flutter run
```

### Build release APK

```bash
flutter build apk --release --split-per-abi
```

## 🔑 Setting up Signing for GitHub Actions

1. Generate a keystore:
   ```bash
   keytool -genkey -v -keystore caturl.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias caturl
   ```

2. Base64 encode it:
   ```bash
   base64 -i caturl.jks | pbcopy   # macOS
   base64 caturl.jks               # Linux
   ```

3. Add these **GitHub Secrets** to your repo:
   | Secret | Value |
   |--------|-------|
   | `KEYSTORE_BASE64` | Base64-encoded keystore |
   | `KEYSTORE_PASSWORD` | Your keystore password |
   | `KEY_ALIAS` | Key alias (e.g. `url_opener`) |
   | `KEY_PASSWORD` | Key password |

## 📦 Releasing

Push a version tag to trigger an automatic release:

```bash
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions will build APKs for all architectures and create a release automatically.

## 🏗️ Project Structure

```
lib/
├── main.dart              # App entry, Material You theme setup
├── models/
│   └── url_entry.dart     # Data model
├── screens/
│   └── home_screen.dart   # Main screen
├── services/
│   ├── url_file_service.dart   # .url file create/parse/open
│   └── intent_handler.dart     # Android intent bridge
└── widgets/
    ├── url_card.dart           # Shortcut list item
    ├── create_url_sheet.dart   # Bottom sheet to create .url
    └── url_open_dialog.dart    # Dialog for incoming files
```

## 📱 `.url` File Format

The app uses the standard Windows Internet Shortcut format:

```ini
[InternetShortcut]
URL=https://example.com
```

These files are compatible with Windows Explorer, macOS, and most Linux file managers.
