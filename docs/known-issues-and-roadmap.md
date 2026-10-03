# Known Issues and Roadmap

Status of the project at the time development was paused.

## Product direction

Gidon helps casual, non-professional riders track rides easily, and
gives children a gamified way to enjoy cycling. Note: CODEX.md and
AGENTS.md still say the app is "not a child-specific product". Update
them before resuming so agents follow the current target audience.
Child accounts, parental controls, and cloud features remain out of scope.

## Known issues

- Orphan GPS points: if the app is killed mid-ride, points without a
  RideMeta stay in the database forever and slow down history loading.
  Idea: on startup, offer to recover or delete the unfinished ride.
- Elevation inconsistency: XP uses terrain-corrected elevation, but
  rides reopened from history recompute elevation from raw GPS altitude,
  so values can differ from what was shown at save time.
- Background tracking works on Android only; iOS is not validated.
- Performance: live stats are recomputed from all points every second,
  and ride history loads every point of every ride into memory.
- Isar 3.x is no longer maintained (an AGP namespace workaround already
  exists in android/build.gradle.kts).
- Fonts are downloaded at runtime by google_fonts (needs internet).
- Platform folders other than android/ and ios/ are Flutter defaults
  and are not supported.

## Roadmap (in priority order)

1. Persist computed summary (distance, duration, speeds, elevation,
   xpEarned) in RideMeta. Fixes the elevation inconsistency, speeds up
   history, and keeps profile and summary screens consistent.
2. Unit tests for RideStatsCalculator, ScoreCalculator, and
   ProfileService.computeProgression, then a basic CI workflow.
3. Rebalance scoring for children: the speed multipliers reward riding
   fast; consider rewarding exploration, distance, and consistency, or
   capping speed rewards.
4. Bundle fonts as assets for offline use.
5. Game modes (Ghost Map, Blind Ride) and the leaderboard.

## Release checklist

- Replace applicationId com.example.gidon and set up release signing
  (release currently uses the debug key).
- Remove ACCESS_BACKGROUND_LOCATION if it stays unused.
- Add a LICENSE file and a real app description in pubspec.yaml.
- Review Google Play Families policy and KVKK/GDPR for location data.
- Check usage policies of the OSM, CyclOSM, and Nominatim tile/geocoding
  services, or move to a dedicated tile provider.