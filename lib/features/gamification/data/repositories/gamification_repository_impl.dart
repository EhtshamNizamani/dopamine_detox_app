import 'package:dartz/dartz.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/gamification.dart';
import '../../domain/repositories/gamification_repository.dart';
import '../datasources/gamification_local_ds.dart';

class GamificationRepositoryImpl implements GamificationRepository {
  final GamificationLocalDataSource dataSource;

  GamificationRepositoryImpl(this.dataSource);

  @override
  Future<Either<String, GamificationEntity>> getGamification() async {
    try {
      final totalXP = dataSource.getTotalXP();
      final level = GamificationEntity.calculateLevel(totalXP);
      final badges = dataSource.getBadges();
      final streak = dataSource.getCurrentStreak();
      final lastCheck = dataSource.getLastStreakCheckDate();
      final lastOpen = dataSource.getLastDailyOpenDate();

      return Right(
        GamificationEntity(
          totalXP: totalXP,
          level: level,
          unlockedBadges: badges,
          currentStreak: streak,
          lastStreakCheckDate: lastCheck,
          lastDailyOpenDate: lastOpen,
        ),
      );
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> addXP(int xp) async {
    try {
      final currentXP = dataSource.getTotalXP();
      final newXP = currentXP + xp;
      await dataSource.setTotalXP(newXP);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> unlockBadge(String badgeId) async {
    try {
      await dataSource.addBadge(badgeId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, bool>> hasBadge(String badgeId) async {
    try {
      final badges = dataSource.getBadges();
      return Right(badges.contains(badgeId));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<String>>> checkAndUnlockBadges({
    required int currentStreak,
    required int currentLevel,
    required int todayScore,
    required int totalLogsCount,
  }) async {
    try {
      final newlyUnlocked = <String>[];
      final badges = dataSource.getBadges();

      // First Log badge
      if (totalLogsCount >= 1 && !badges.contains(AppConstants.badgeFirstLog)) {
        await dataSource.addBadge(AppConstants.badgeFirstLog);
        newlyUnlocked.add(AppConstants.badgeFirstLog);
      }

      // Streak badges
      if (currentStreak >= 3 && !badges.contains(AppConstants.badgeStreak3)) {
        await dataSource.addBadge(AppConstants.badgeStreak3);
        newlyUnlocked.add(AppConstants.badgeStreak3);
      }
      if (currentStreak >= 7 && !badges.contains(AppConstants.badgeStreak7)) {
        await dataSource.addBadge(AppConstants.badgeStreak7);
        newlyUnlocked.add(AppConstants.badgeStreak7);
      }
      if (currentStreak >= 10 && !badges.contains(AppConstants.badgeStreak10)) {
        await dataSource.addBadge(AppConstants.badgeStreak10);
        newlyUnlocked.add(AppConstants.badgeStreak10);
      }

      // Level badges
      if (currentLevel >= 5 && !badges.contains(AppConstants.badgeLevel5)) {
        await dataSource.addBadge(AppConstants.badgeLevel5);
        newlyUnlocked.add(AppConstants.badgeLevel5);
      }
      if (currentLevel >= 10 && !badges.contains(AppConstants.badgeLevel10)) {
        await dataSource.addBadge(AppConstants.badgeLevel10);
        newlyUnlocked.add(AppConstants.badgeLevel10);
      }

      // Perfect Day badge
      if (todayScore == 100 &&
          totalLogsCount > 0 && // ← YE CONDITION ADD KARO
          !badges.contains(AppConstants.badgePerfectDay)) {
        await dataSource.addBadge(AppConstants.badgePerfectDay);
        newlyUnlocked.add(AppConstants.badgePerfectDay);
      }

      return Right(newlyUnlocked);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> updateStreak(int newStreak) async {
    try {
      await dataSource.setCurrentStreak(newStreak);
      await dataSource.setLastStreakCheckDate(DateTime.now());
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, int>> getCurrentStreak() async {
    try {
      return Right(dataSource.getCurrentStreak());
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, bool>> checkDailyOpenXP() async {
    try {
      final lastOpen = dataSource.getLastDailyOpenDate();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (lastOpen == null ||
          DateTime(lastOpen.year, lastOpen.month, lastOpen.day) != today) {
        // First open today - award XP
        final currentXP = dataSource.getTotalXP();
        await dataSource.setTotalXP(currentXP + AppConstants.xpDailyOpen);
        await dataSource.setLastDailyOpenDate(now);
        return Right(true); // XP awarded
      }
      return Right(false); // Already opened today
    } catch (e) {
      return Left(e.toString());
    }
  }
}
