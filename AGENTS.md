# Agent Instructions

These instructions apply to the whole repository.

## Communication

- Talk to the user in Turkish.
- Keep explanations concise, direct, and analytical.
- Write all code assets in English, including identifiers, comments, documentation, and commit messages.

## First Read

Before changing code, read:

- `CODEX.md`
- `README.md`
- The files directly related to the requested feature or bug.

## Project Boundaries

- Gidon is a Flutter cycling app focused on casual ride tracking, exploration, local ride history, mini games, and playful progression.
- The primary users are casual amateur cyclists and younger or game-motivated riders.
- Normal ride tracking should stay simple and practical; game modes may feel more like a video game.
- Keep the app local-first unless the user explicitly asks for cloud or account features.
- Do not add authentication, sync, subscriptions, social features, parent controls, child accounts, guardian dashboards, or backend APIs without a clear request.
- Do not add features only because they are common in professional cycling apps; every feature should improve user experience, motivation, clarity, safety, or ride review value.

## Feature Design

- Discuss the product and UI direction of meaningful new features before implementation.
- Identify whether the feature serves casual cyclists, game-motivated riders, or both.
- Decide whether the feature belongs in normal ride tracking, game modes, profile/progression, history/review, or settings.
- Keep ride-time interactions simple and avoid unnecessary distraction.
- Prefer improving existing flows over adding unrelated surfaces.

## Architecture Rules

- Put reusable ride, GPS, scoring, and persistence logic under `lib/services/`.
- Keep feature UI under `lib/features/`.
- Keep shared visual constants under `lib/theme/`.
- Avoid placing core business calculations directly in widgets.
- Prefer existing patterns over introducing new frameworks or packages.

## Flutter And Isar

- Do not edit generated `*.g.dart` files manually.
- After changing an Isar `@collection` model, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

- Validate meaningful changes with the narrowest useful command first, such as:

```bash
flutter analyze
flutter test
```

## Safety

- Do not revert or overwrite user changes unless explicitly requested.
- Do not run destructive git commands.
- Do not create commits or branches unless explicitly requested.
- Do not introduce packages for simple problems that can be solved with existing dependencies.
