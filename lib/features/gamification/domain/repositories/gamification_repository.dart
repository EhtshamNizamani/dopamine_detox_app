import 'package:dartz/dartz.dart';
import 'package:dopamine_detox_app/features/gamification/domain/entities/gamification.dart';

abstract class GamificationRepository {
  Future<Either<String, GamificationEntity>> getGamification();
  Future<Either<String, void>> addXP(int xp);
  Future<Either<String, void>> unlockBadge(String badgeId);
  Future<Either<String, bool>> hasBadge(String badgeId);
}