# Gidon

Gidon is a Flutter cycling app that makes ride tracking easy for
non-professional riders and turns riding into a game for kids and
game-motivated cyclists.

## Features

- Map-first ride recording with live speed, distance, elevation, and
  moving time
- Android background tracking via a foreground service
- Noise filtering and auto-pause for accurate ride statistics
- Save, name, review, and delete rides (local-first, no account needed)
- XP, levels, gold, and speed/consistency multipliers
- Profile with lifetime stats and recent rides
- Map layers (cycling, terrain, satellite) and place search

## Platform support

| Platform | Status |
|----------|--------|
| Android  | Supported (including background tracking) |
| iOS      | Builds, background tracking not validated |
| Others   | Flutter defaults only, not supported |

## Getting started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Run code generation again after changing any Isar `@collection` model.

Useful checks:

```bash
flutter analyze
flutter test
```

## Project structure

- `lib/main.dart`: app entry point (Isar, permissions, background service)
- `lib/features/`: screens grouped by feature
- `lib/services/location/`: GPS persistence, ride stats, route filtering, elevation lookup
- `lib/services/scoring/`: XP, levels, rewards, profile persistence
- `lib/services/background/`: Android background tracking isolate
- `lib/theme/`: shared colors and typography

## Documentation

- [CODEX.md](CODEX.md): project context, architecture, and rules
- [AGENTS.md](AGENTS.md): instructions for AI coding agents
- [docs/known-issues-and-roadmap.md](docs/known-issues-and-roadmap.md): known issues, next steps, release checklist

## Status

Development is currently paused. See the roadmap before resuming.