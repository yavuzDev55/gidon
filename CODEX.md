# Gidon Project Context

This document is the project memory for Codex and other AI coding agents. Read it before changing code.

## Product Purpose

Gidon is a Flutter cycling app centered on ride recording, exploration, and playful motivation. Its current identity is a map-first bike ride tracker that can feel simple and practical during normal rides, while gradually adding a more game-like layer through XP, levels, mini games, and visual feedback.

The app is not intended to be a professional cycling analytics tool. It should avoid unnecessary technical complexity in the user experience and focus on making everyday riding more enjoyable, understandable, and motivating.

Primary user groups:

- Casual amateur cyclists who ride for medium-length trips, exploration, commuting, or light fitness, and want an easy ride tracker without professional training complexity.
- Younger or game-motivated riders who are attracted by mini games, XP, levels, rewards, and a stronger video-game-like feeling.

Current child-related boundary:

- The project may appeal to children through game-like mechanics, but it is not currently a child-specific product.
- Do not add parent controls, child accounts, guardian dashboards, or child safety workflows unless explicitly requested later.

The core user journey is:

1. Open the app on the live map.
2. Grant location and notification permissions.
3. Start a ride.
4. Record GPS points in the foreground UI and Android background service.
5. Stop the ride.
6. Review XP and ride statistics.
7. Save the ride with a name and optional description.
8. View saved rides and lifetime profile stats later.

## Current Scope

In scope:

- Flutter mobile app structure.
- Android foreground background location tracking.
- Local-first storage through Isar.
- GPS point recording, filtering, and ride stat calculation.
- Map display with route polyline, current position, heading, and layer switching.
- Ride history and profile summary screens.
- XP, level, multiplier, and gold progression.
- Basic map search/geocoding.
- Game-inspired UI feedback around ride completion, progression, profile, and mini games.

Out of scope unless explicitly requested:

- Cloud accounts, sync, social features, leaderboards, or authentication.
- Parent controls, child accounts, or guardian-facing monitoring.
- Paid subscription logic.
- Server-side APIs owned by this app.
- Complex game systems beyond the existing lightweight progression direction.
- Replacing Isar or the current Flutter architecture without a migration reason.
- Large UI redesigns unrelated to a requested feature.

## Architecture Overview

The project is organized by simple feature folders and shared services. It is not using a formal state-management framework yet.

- `lib/main.dart` is the app entry point. It initializes Flutter bindings, opens Isar, prepares permissions, registers the background service, and starts `GidonApp`.
- `lib/features/navigation/main_navigation_screen.dart` hosts the main tabs: ride map, profile, and games. The ride screen is kept alive while switching tabs.
- `lib/features/live_tracking/live_tracking_screen.dart` owns the ride recording UI state and coordinates foreground UI updates with the Android background service.
- `lib/services/background/background_service.dart` is the Android background isolate entry point. It opens its own Isar connection and writes GPS points while a ride is active.
- `lib/services/location/` owns GPS data, storage, stats, route filtering, and elevation support.
- `lib/services/scoring/` owns XP, level, profile, and reward logic.
- `lib/theme/` owns visual constants.

Keep business rules in services when possible. Keep widgets focused on composition, navigation, and UI state.

## Data Model

Isar collections:

- `GpsPoint`: one raw GPS reading captured during a ride. It includes `rideId`, latitude, longitude, altitude, speed, accuracy, and UTC timestamp.
- `RideMeta`: user-facing metadata for a saved ride. A ride only appears in history after a `RideMeta` record exists.
- `UserProfile`: persistent rider stats, level, XP, gold, lifetime distance, duration, max speed, and elevation.

Important persistence rule:

- GPS points can exist before a ride is saved.
- A completed ride is treated as saved only after `RideMeta` is written.
- Deleting a saved ride removes `GpsPoint` and `RideMeta`, but does not reverse aggregate `UserProfile` rewards.

After changing any `@collection` model, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Ride Recording Flow

App startup:

- `main.dart` initializes Isar.
- Notification permission is requested.
- `initializeBackgroundService()` configures the Android foreground service.

Ride start:

- `LiveTrackingScreen` creates a UTC ISO ride id.
- It starts the background service if needed.
- It waits briefly for the service `ready` signal.
- It invokes `startRide` with the ride id.
- It enables wakelock.
- A timer refreshes stats from Isar every second.

Background recording:

- `onServiceStart` runs in a separate isolate.
- It opens a separate Isar connection.
- It listens to `Geolocator.getPositionStream`.
- It writes each `GpsPoint` to Isar.
- It updates the Android foreground notification with speed.

Ride stop:

- The UI invokes `stopRide`.
- Wakelock is disabled.
- Points are loaded from Isar.
- Very short rides are deleted automatically.
- Elevation may be recalculated from sampled terrain data.
- XP is evaluated.
- The user sees progression, then confirms or discards the ride.

## Statistics Rules

`RideStatsCalculator` is the source of truth for ride statistics.

Current rules:

- Points worse than 15 meters accuracy are ignored in calculations.
- Segments shorter than 3 meters are treated as GPS noise.
- Slow stretches below 5 km/h for at least 30 seconds are excluded from moving stats.
- Distance uses haversine distance between accepted points.
- Moving duration excludes auto-paused stretches.
- Elevation gain counts positive altitude movement, with a separate noise-aware helper for external elevation samples.
- Display routes are filtered separately to avoid jittery map lines.

Do not duplicate these calculations in widgets.

## Scoring Rules

`ScoreCalculator` is the source of truth for ride XP.

Current rules:

- Base distance XP: 25 XP per kilometer.
- Elevation XP: 8 XP per 10 meters climbed.
- Duration XP: 3 XP per 10 moving minutes.
- High Speed multiplier: x3 at 20 km/h or above.
- Consistency multiplier: x2 after 1000 meters at 15 km/h or above.
- Multipliers affect distance XP.
- Live multiplier UI uses the latest active multiplier state.

`ProfileService` applies saved ride rewards:

- XP rolls over into levels.
- Each level gained grants 50 gold.
- Monthly XP resets when `xpPeriod` changes.
- Lifetime totals are cumulative and are not linked back to deletable ride history.

## UI Direction

Current UI language:

- High-contrast black, white, and yellow.
- Map-first ride screen.
- Circular start/stop interactions.
- Compact stat panels.
- Profile screen with lifetime stats and recent rides.

Respect the existing visual identity when adding features. Prefer small, coherent additions over broad redesigns.

Experience principles:

- Normal ride tracking should stay simple, readable, and low-friction.
- Game modes and mini games may lean more strongly into a video game feeling.
- XP, levels, rewards, and ride-completion screens should make progress feel satisfying without burying the core tracking task.
- Avoid meaningless features. Every new feature should improve motivation, clarity, delight, safety, or ride review value.
- Do not turn the app into a dense professional analytics dashboard unless that direction is explicitly chosen later.

Feature design process:

- Discuss the product and UI design of each meaningful new feature before implementation.
- Clarify which user group the feature primarily serves.
- Decide whether the feature belongs in normal ride tracking, game modes, profile/progression, history/review, or settings.
- Keep ride-time interactions simple enough to avoid unnecessary distraction.
- Prefer improving the existing experience over adding unrelated surfaces.

## Agent Guardrails

- Communicate with the user in Turkish.
- Write code, comments, docs, identifiers, and commit messages in English.
- Read this file and `AGENTS.md` before making changes.
- For meaningful new features, discuss the design direction with the user before implementing.
- Identify whether the change serves casual cyclists, game-motivated riders, or both.
- Prefer minimal, focused changes that match existing folder boundaries.
- Do not introduce new packages unless the requested feature truly needs them.
- Keep location/stat/scoring business logic out of widgets where practical.
- Do not change generated `*.g.dart` files manually.
- Do not overwrite user changes or clean the working tree without explicit approval.
- For generated Isar model changes, update source models first and regenerate.
- For behavior changes, run the narrowest useful validation command first.

## Known Gaps And Risks

- There is no formal state-management layer yet; large features can make screen state heavy.
- Background tracking is Android-oriented; iOS behavior needs separate validation before claiming support.
- `README.md` previously contained only the default Flutter template text.
- Git commands may require marking the repository as a safe directory in sandboxed Codex sessions.
- Test coverage appears minimal; core calculators are good candidates for focused unit tests.

## Suggested Next Documentation

Useful future additions:

- `docs/product.md` for product vision, personas, and non-goals.
- `docs/architecture.md` if the service graph grows.
- `docs/decisions/` for architectural decision records.
- Focused unit tests for `RideStatsCalculator`, `ScoreCalculator`, and `ProfileService.computeProgression`.
