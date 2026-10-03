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
- `docs/known-issues-and-roadmap.md`
- The files directly related to the requested feature or bug.

## Project Boundaries

- Gidon is a Flutter cycling app focused on easy ride tracking for non-professional riders, exploration, route planning, local ride history, and a gamified riding experience for children and game-motivated riders.
- The primary users are casual amateur cyclists and children (or younger riders) who are motivated by games, XP, and levels.
- Normal ride tracking should stay simple and practical; game modes may feel more like a video game.
- Because children are a target audience, favor safe, age-appropriate design: no pressure to ride fast, no unnecessary data collection, and no content that is unsuitable for young users.
- Keep the app local-first unless the user explicitly asks for cloud or account features.
- Do not add authentication, sync, subscriptions, social features, child accounts, parental controls, guardian dashboards, or backend APIs without a clear request. These are out of scope for now, not rejected for good.
- Do not add features only because they are common in professional cycling apps; every feature should improve user experience, motivation, clarity, safety, or ride review value.

## Feature Design

- Discuss the product and UI direction of meaningful new features before implementation.
- Identify whether the feature serves casual cyclists, children and game-motivated riders, or both.
- Decide whether the feature belongs in normal ride tracking, route planning, game modes, profile/progression, history/review, or settings.
- Keep ride-time interactions simple and avoid unnecessary distraction.
- Prefer improving existing flows over adding unrelated surfaces.
- Scoring changes should not push children toward unsafe riding (for example, rewarding high speed). See the roadmap before touching multipliers.

## Architecture Rules

- Put reusable ride, GPS, scoring, routing, and persistence logic under `lib/services/`.
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

## Documentation

- Keep `README.md` short and current.
- Record new known issues, roadmap items, and release blockers in `docs/known-issues-and-roadmap.md`.
- When a change affects the product direction, architecture, data model, or scoring rules, update `CODEX.md` in the same change.

## Safety

- Do not revert or overwrite user changes unless explicitly requested.
- Do not run destructive git commands.
- Do not create commits or branches unless explicitly requested.
- Do not introduce packages for simple problems that can be solved with existing dependencies.