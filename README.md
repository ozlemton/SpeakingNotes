# 🎙️ SpeakingNotes

> **Your voice. Your notes. Automatically.**
> SpeakingNotes listens to your conversations and transforms them into organized, searchable notes — hands-free.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-lightgrey?style=for-the-badge)
![Version](https://img.shields.io/badge/Version-1.0.0-success?style=for-the-badge)

---

## ✨ Features

- 🎤 **Voice-to-Text Notes** — Speak naturally and watch your words become notes in real time
- 📁 **Smart Categories** — Organize notes into categories created entirely by voice
- 🗂️ **Persistent Storage** — All categories and notes are saved and available anytime
- ➕ **Add to Existing Categories** — Select a category and keep adding new notes to it
- 🧠 **Hands-Free Experience** — No typing required at any step

---

## 📱 How It Works

```
1. Open the app
       ↓
2. Tap "+ New Category"
       ↓
3. Speak the category name → converted to text automatically
       ↓
4. Start speaking your note → everything you say is saved as a note
       ↓
5. All notes are stored under their category and listed in the app
```

> Already have a category? Simply select it from the list and start adding new notes to it.

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `^3.8.1`
- Dart SDK *(included with Flutter)*
- Xcode *(for iOS)* or Android Studio *(for Android)*
- A physical device or simulator with microphone access

### Installation

```bash
# 1. Clone the repository
git clone <repository-url>
cd speaking_notes

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

---

## 🗂️ Project Structure

```
speaking_notes/
├── lib/
│   └── main.dart              # App entry point
├── test/
│   └── widget_test.dart       # Widget tests
├── android/                   # Android configuration
├── ios/                       # iOS configuration
├── web/                       # Web configuration
├── macos/                     # macOS configuration
├── windows/                   # Windows configuration
├── linux/                     # Linux configuration
└── pubspec.yaml               # Dependencies & metadata
```

---

## 📦 Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter` | SDK | UI framework |
| `cupertino_icons` | ^1.0.8 | iOS-style icons |

---

## 🌍 Platform Support

| Platform | Status |
|----------|--------|
| 📱 Android | ✅ Supported |
| 🍎 iOS | ✅ Supported |
| 🌐 Web | ✅ Supported |
| 🖥️ macOS | ✅ Supported |
| 🪟 Windows | ✅ Supported |
| 🐧 Linux | ✅ Supported |

---

## 🧪 Running Tests

```bash
flutter test
```

---

## 🔨 Build

```bash
# Android
flutter build apk

# iOS
flutter build ios

# Web
flutter build web
```

---

## 🔒 Permissions

SpeakingNotes requires the following device permissions:

- 🎙️ **Microphone** — for voice-to-text conversion

---

## 📄 License

This project is licensed under the MIT License.

---

*Made with ❤️ using Flutter*
