# SpeakingNotes

> Voice-powered note taking app for iOS and Android

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-lightgrey?style=for-the-badge)
![Version](https://img.shields.io/badge/Version-1.0.0-success?style=for-the-badge)

---

## Features

- **Speech-to-text note taking** — dictate notes in 33 supported languages
- **Category management** — organise notes into categories, created by voice or text
- **Local + Firebase cloud sync** — notes are saved to SQLite on-device and synced to Firestore
- **Multi-language UI** — full Turkish and English localisation with live switching
- **Note editing** — edit saved notes with a rich text editor
- **Search** — search across all notes in real time

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter (Clean Architecture) |
| State management | BLoC (`flutter_bloc`) |
| Navigation | `go_router` |
| Local storage | Drift (SQLite) |
| Cloud storage | Firebase Firestore |
| Authentication | Firebase Auth |
| Responsive design | `flutter_screenutil` |
| Localisation | Flutter `intl` (TR / EN) |
| Dependency injection | `get_it` |

---

## Architecture

The project follows Clean Architecture with feature-first folder organisation:

```
lib/
├── core/
│   ├── constants/          # AppAssets
│   ├── navigation/         # go_router route definitions
│   ├── services/           # SpeechService, SyncService, RepositoryService
│   └── theme/              # AppColors, AppTypography, AppSpacing, AppTheme
├── features/
│   ├── auth/
│   │   ├── data/           # FirebaseAuthRepository
│   │   ├── domain/         # models, repository interface, use cases
│   │   └── presentation/   # AuthBloc, LoginScreen, SignupScreen, ProfileScreen
│   ├── category/
│   │   ├── data/           # FirebaseCategoryRepository, LocalCategoryRepository
│   │   ├── domain/
│   │   └── presentation/   # CategoryBloc, HomeScreen
│   ├── note/
│   │   ├── data/           # FirebaseNoteRepository, LocalNoteRepository
│   │   ├── domain/
│   │   └── presentation/   # NoteBloc, CategoryScreen, NoteDetailScreen
│   └── splash/
│       └── presentation/   # SplashScreen
├── l10n/                   # ARB files + generated localisation classes
└── main.dart
```

**Data flow:** UI → BLoC event → Use Case → Repository → local Drift DB (always) + Firebase Firestore (best-effort, fire-and-forget).

---

## Setup

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `>=3.8.1`
- Xcode (iOS) or Android Studio (Android)
- A Firebase project with Authentication and Firestore enabled
- A physical device or simulator with microphone access

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/ozlemton/SpeakingNotes.git
cd speaking_notes

# 2. Install dependencies
flutter pub get

# 3. Add Firebase config files
#    iOS:     ios/Runner/GoogleService-Info.plist
#    Android: android/app/google-services.json
#    Dart:    lib/firebase_options.dart
#    (generate with: flutterfire configure)

# 4. Run the app
flutter run
```

### Build

```bash
# Android release APK
flutter build apk --release

# iOS release (requires Xcode signing configured)
flutter build ios --release
```

---

## Testing

The project has 36 unit and BLoC tests covering use cases and the NoteBloc:

```bash
flutter test
```

CI/CD runs automatically on every push and pull request via GitHub Actions (`.github/workflows/ci.yml`):

- `flutter analyze` — static analysis
- `flutter test` — full test suite

---

## Permissions

| Permission | Reason |
|------------|--------|
| Microphone | Speech-to-text transcription |
| Internet | Firebase authentication and Firestore sync |

---

## Privacy

See [docs/privacy_policy.md](docs/privacy_policy.md) for the full privacy policy (EN / TR).

---

## Firebase Security

See [docs/firebase_security_rules.md](docs/firebase_security_rules.md) for Firestore security rules — users can only access their own data.

---

## License

This project is licensed under the MIT License.
