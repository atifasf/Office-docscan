# ScanVerse AI 📄✨
### Premium AI Document Scanner — Flutter

---

## 🚀 Features
| Feature | Status |
|---|---|
| 📸 Camera Scanner | ✅ |
| 🖼️ Gallery Import | ✅ |
| 🔍 AI OCR (ML Kit) | ✅ |
| 📄 PDF Export | ✅ |
| 🔗 Share / Open PDF | ✅ |
| 🖨️ Print PDF | ✅ |
| ⭐ Favourites | ✅ |
| 🔎 Search Scans & Text | ✅ |
| 🌙 Dark Mode | ✅ |
| 💾 Offline Storage (SQLite) | ✅ |

---

## 📁 Project Structure

```
scanverse/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── core/
│   │   ├── theme/app_theme.dart           # Material 3 Dark theme
│   │   ├── constants/app_constants.dart   # App-wide constants
│   │   └── utils/database_helper.dart     # SQLite CRUD
│   └── features/
│       ├── home/presentation/screens/
│       │   ├── home_screen.dart           # Bottom nav shell
│       │   └── settings_screen.dart       # Settings
│       ├── scanner/
│       │   ├── data/scan_model.dart       # Data model
│       │   ├── providers/scanner_provider.dart  # State
│       │   └── presentation/screens/
│       │       ├── camera_screen.dart     # Capture / Gallery
│       │       ├── scan_preview_screen.dart # Preview + actions
│       │       └── scan_list_screen.dart  # All scans list
│       ├── ocr/
│       │   ├── providers/ocr_provider.dart # ML Kit OCR
│       │   └── presentation/screens/
│       │       └── ocr_result_screen.dart  # View / edit / share text
│       └── pdf/
│           ├── providers/pdf_provider.dart # PDF generation
│           └── presentation/screens/
│               └── pdf_list_screen.dart    # PDF library
└── android/
    ├── app/src/main/
    │   ├── AndroidManifest.xml
    │   └── res/xml/file_paths.xml
    └── app/build.gradle
```

---

## ⚙️ Setup Instructions

### 1. Prerequisites
```bash
flutter --version   # >= 3.22.0
dart --version      # >= 3.3.0
```

### 2. Clone & Install
```bash
cd scanverse
flutter pub get
```

### 3. Assets Setup
```bash
mkdir -p assets/images assets/animations assets/icons assets/fonts
```

> Add your app fonts to `assets/fonts/` or remove font references from `pubspec.yaml`

### 4. Run the App
```bash
# Debug mode
flutter run

# Release mode
flutter run --release
```

---

## 📦 Build APK

### Debug APK
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK
```bash
flutter build apk --release --split-per-abi
# Output: build/app/outputs/flutter-apk/
#   app-arm64-v8a-release.apk    ← use this for most modern phones
#   app-armeabi-v7a-release.apk  ← older 32-bit devices
#   app-x86_64-release.apk       ← emulators
```

### Universal APK (one file for all)
```bash
flutter build apk --release
```

---

## 🔑 Signing for Play Store

1. Generate keystore:
```bash
keytool -genkey -v -keystore ~/scanverse-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias scanverse
```

2. Create `android/key.properties`:
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=scanverse
storeFile=../../../scanverse-key.jks
```

3. Update `android/app/build.gradle` to use signing config.

4. Build signed APK:
```bash
flutter build apk --release
```

---

## 📱 Minimum Requirements
- Android 6.0+ (API 23)
- Camera permission
- Storage permission

---

## 🔧 Key Dependencies
| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management |
| `google_mlkit_text_recognition` | OCR engine |
| `pdf` + `printing` | PDF generation & print |
| `share_plus` | Share files |
| `image_picker` | Camera + gallery |
| `sqflite` | Local database |
| `flutter_animate` | Animations |
| `open_filex` | Open PDF viewer |

---

## 🚀 Play Store Publishing

1. Build App Bundle (preferred):
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

2. Upload `.aab` to Google Play Console
3. Required assets: screenshots (min 2), feature graphic (1024×500)
4. Set content rating, pricing, distribution

---

## 📝 Notes
- OCR works **fully offline** using Google ML Kit
- PDFs saved to app's documents directory
- Search works across both scan titles AND OCR text
- Urdu/Hindi OCR: toggle in Settings → Devanagari script

---

*Built with Flutter + Riverpod + Google ML Kit*
*ScanVerse AI © 2024*
