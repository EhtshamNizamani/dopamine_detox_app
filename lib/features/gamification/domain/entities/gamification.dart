import 'package:equatable/equatable.dart';

class GamificationEntity extends Equatable {
  final int totalXP;
  final int level;
  final List<String> unlockedBadges;

  const GamificationEntity({
    required this.totalXP,
    required this.level,
    required this.unlockedBadges,
  });

  @override
  List<Object?> get props => [totalXP, level, unlockedBadges];

  // Helper to get XP needed for next level
  int get xpForNextLevel {
    int nextLevel = level + 1;
    return nextLevel * 100; // Level 2 needs 200 XP, Level 3 needs 300, etc.
  }

  int get currentLevelProgress => totalXP - ((level - 1) * 100);
}