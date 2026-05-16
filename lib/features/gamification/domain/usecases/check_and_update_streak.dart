import 'package:dartz/dartz.dart';
import 'package:dopamine_detox_app/core/constants/app_constants.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/entities/log_entry_entity.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/usecases/calculate_score.dart';
import '../../domain/repositories/gamification_repository.dart';

class CheckAndUpdateStreakUseCase {
  final GamificationRepository gamificationRepository;

  CheckAndUpdateStreakUseCase(this.gamificationRepository);

  /// Idempotent: Ek din mein sirf ek baar XP award hoga.
  Future<Either<String, StreakUpdateResult>> call(List<LogEntryEntity> todayLogs) async {
    try {
            if (todayLogs.isEmpty) {
        final currentStreakResult = await gamificationRepository.getCurrentStreak();
        final currentStreak = currentStreakResult.fold((l) => 0, (r) => r);
        return Right(StreakUpdateResult(
          newStreak: currentStreak,
          xpAwarded: 0,
          wasPerfectDay: false,
          todayScore: AppConstants.maxDopamineScore,
        ));
      }

      final score = CalculateScore.calculate(todayLogs);
      final isValid = CalculateScore.isStreakValid(score);
      final isPerfect = CalculateScore.isPerfectDay(score);

      // ── Guard: Aaj already check ho chuka hai? ──
      final gamificationResult = await gamificationRepository.getGamification();
      final lastCheckDate = gamificationResult.fold(
        (l) => null,
        (r) => r.lastStreakCheckDate,
      );

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (lastCheckDate != null) {
        final lastCheck = DateTime(lastCheckDate.year, lastCheckDate.month, lastCheckDate.day);
        if (lastCheck == today) {
          // Pehle hi process kiya hai aaj → kuch mat karo
          final currentStreakResult = await gamificationRepository.getCurrentStreak();
          final currentStreak = currentStreakResult.fold((l) => 0, (r) => r);
          return Right(StreakUpdateResult(
            newStreak: currentStreak,
            xpAwarded: 0,
            wasPerfectDay: isPerfect,
            todayScore: score,
          ));
        }
      }

      // ── First time today ──
      final currentStreakResult = await gamificationRepository.getCurrentStreak();
      final currentStreak = currentStreakResult.fold((l) => 0, (r) => r);

      int newStreak;
      int xpAwarded = 0;

      if (isValid) {
        newStreak = currentStreak + 1;
        xpAwarded += AppConstants.xpGoodDay;
        if (isPerfect) {
          xpAwarded += (AppConstants.xpPerfectDay - AppConstants.xpGoodDay);
        }
        if (currentStreak > 0) {
          xpAwarded += AppConstants.xpStreakMaintain;
        }
      } else {
        newStreak = 0;
      }

      await gamificationRepository.updateStreak(newStreak);
      if (xpAwarded > 0) {
        await gamificationRepository.addXP(xpAwarded);
      }

      return Right(StreakUpdateResult(
        newStreak: newStreak,
        xpAwarded: xpAwarded,
        wasPerfectDay: isPerfect,
        todayScore: score,
      ));
    } catch (e) {
      return Left(e.toString());
    }
  }
}

class StreakUpdateResult {
  final int newStreak;
  final int xpAwarded;
  final bool wasPerfectDay;
  final int todayScore;

  StreakUpdateResult({
    required this.newStreak,
    required this.xpAwarded,
    required this.wasPerfectDay,
    required this.todayScore,
  });
}
