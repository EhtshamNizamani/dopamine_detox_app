import 'package:equatable/equatable.dart';

class GamificationEntity extends Equatable {
  final int totalXP;
  final int level;
  final List<String> unlockedBadges;
  final int currentStreak;
  final DateTime? lastStreakCheckDate;
  final DateTime? lastDailyOpenDate;

  const GamificationEntity({
    required this.totalXP,
    required this.level,
    required this.unlockedBadges,
    this.currentStreak = 0,
    this.lastStreakCheckDate,
    this.lastDailyOpenDate,
  });

  @override
  List<Object?> get props => [totalXP, level, unlockedBadges, currentStreak, lastStreakCheckDate, lastDailyOpenDate];

  /// Get XP needed for next level based on level thresholds
int get xpForNextLevel {
  const thresholds = {
    1: 100, 2: 250, 3: 400, 4: 500, 5: 600, 
    6: 700, 7: 800, 8: 900, 9: 1000, 10: 1000,
  };
  return thresholds[level] ?? (level * 100);
}

  int get currentLevelProgress {
    final prevThreshold = _getThresholdForLevel(level);
    return totalXP - prevThreshold;
  }

int _getThresholdForLevel(int lvl) {
  const thresholds = {
    1: 0, 2: 100, 3: 250, 4: 400, 5: 500,
    6: 600, 7: 700, 8: 800, 9: 900, 10: 1000,
  };
  return thresholds[lvl] ?? ((lvl - 1) * 100);
}

static int calculateLevel(int totalXP) {
  if (totalXP >= 1000) return 10;  // Level 10
  if (totalXP >= 900) return 9;     // Level 9
  if (totalXP >= 800) return 8;     // Level 8
  if (totalXP >= 700) return 7;     // Level 7  (adjust kar sakte ho)
  if (totalXP >= 600) return 6;     // Level 6  (adjust kar sakte ho)
  if (totalXP >= 500) return 5;     // Level 5 ✅ Ab sahi jagah pe hai
  if (totalXP >= 400) return 4;     // Level 4
  if (totalXP >= 250) return 3;     // Level 3
  if (totalXP >= 100) return 2;     // Level 2
  return 1;                        // Level 1 (0-99)
}
}