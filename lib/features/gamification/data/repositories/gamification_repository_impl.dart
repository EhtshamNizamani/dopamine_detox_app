import 'package:dartz/dartz.dart';
import 'package:dopamine_detox_app/features/gamification/data/datasources/gamification_local_ds.dart';
import 'package:dopamine_detox_app/features/gamification/domain/entities/gamification.dart';
import 'package:dopamine_detox_app/features/gamification/domain/repositories/gamification_repository.dart';
class GamificationRepositoryImpl implements GamificationRepository {
  final GamificationLocalDataSource dataSource;

  GamificationRepositoryImpl(this.dataSource);

  @override
  Future<Either<String, GamificationEntity>> getGamification() async {
    try {
      final totalXP = dataSource.getTotalXP();
      final level = _calculateLevel(totalXP);
      final badges = dataSource.getBadges();
      return Right(GamificationEntity(
        totalXP: totalXP,
        level: level,
        unlockedBadges: badges,
      ));
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

      // Auto-unlock level-based badges
      final newLevel = _calculateLevel(newXP);
      final oldLevel = _calculateLevel(currentXP);
      if (newLevel >= 5 && oldLevel < 5) {
        await unlockBadge('Level 5');
      }

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

  int _calculateLevel(int totalXP) {
    return 1 + (totalXP ~/ 100);
  }
}