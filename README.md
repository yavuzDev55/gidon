# Gidon

Gidon is a Flutter cycling companion focused on ride tracking, map-first recording, ride history, and lightweight progression mechanics.

The app currently targets a local-first mobile experience:

- Records GPS points during a ride, including background tracking on Android.
- Shows live map position, route drawing, speed, distance, elevation, and moving time.
- Filters noisy or inaccurate GPS points before computing ride statistics.
- Lets riders save, name, review, and delete completed rides.
- Applies XP, level, and gold rewards when a ride is confirmed.
- Keeps profile totals separate from ride history deletion.

## Project Map

Start with [CODEX.md](CODEX.md) before making changes. It explains the product goal, current boundaries, architecture, data model, scoring rules, and development guardrails for AI agents and human contributors.

## Main Folders

- `lib/main.dart` initializes Isar, permissions, Android background tracking, and the root app.
- `lib/features/` contains user-facing screens grouped by feature.
- `lib/services/location/` contains GPS persistence, ride statistics, route filtering, and elevation lookup logic.
- `lib/services/scoring/` contains XP, level, reward, and profile persistence logic.
- `lib/theme/` contains shared colors and typography.
- `test/` contains Flutter tests.

## Development Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter run
```

Run code generation after changing any Isar collection model.
