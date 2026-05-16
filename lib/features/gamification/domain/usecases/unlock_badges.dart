import 'package:dartz/dartz.dart';
import '../../domain/repositories/gamification_repository.dart';

class UnlockBadgesUseCase {
  final GamificationRepository repository;

  UnlockBadgesUseCase(this.repository);

  /// Check all badge criteria and return newly unlocked badges
  Future<Either<String, List<String>>> call({
    required int currentStreak,
    required int currentLevel,
    required int todayScore,
    required int totalLogsCount,
  }) async {
    return await repository.checkAndUnlockBadges(
      currentStreak: currentStreak,
      currentLevel: currentLevel,
      todayScore: todayScore,
      totalLogsCount: totalLogsCount,
    );
  }
}