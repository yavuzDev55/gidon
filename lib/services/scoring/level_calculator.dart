/// Provides the XP threshold needed to advance from one level to
/// the next. Level and XP progress are now stored directly on the
/// profile (not derived from a cumulative lifetime total), so this
/// class only needs to expose the threshold formula itself.
class LevelCalculator {
  /// XP required to go from [level] to [level + 1].
  static int xpRequiredForLevel(int level) => 100 + (level - 1) * 50;
}
