import 'package:dartz/dartz.dart';
import '../entities/gamification.dart';

abstract class GamificationRepository {
  Future<Either<String, GamificationEntity>> getGamification();
  Future<Either<String, void>> addXP(int xp);
  Future<Either<String, void>> unlockBadge(String badgeId);
  Future<Either<String, bool>> hasBadge(String badgeId);
  
  /// Check all badge criteria and unlock applicable ones
  /// Returns list of newly unlocked badge IDs
  Future<Either<String, List<String>>> checkAndUnlockBadges({
    required int currentStreak,
    required int currentLevel,
    required int todayScore,
    required int totalLogsCount,
  });
  
  Future<Either<String, void>> updateStreak(int newStreak);
  Future<Either<String, int>> getCurrentStreak();
  
  /// Check if daily open XP should be awarded
  /// Returns true if XP was awarded, false if already claimed today
  Future<Either<String, bool>> checkDailyOpenXP();
}