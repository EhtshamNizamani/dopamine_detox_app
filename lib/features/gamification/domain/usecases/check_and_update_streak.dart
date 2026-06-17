import 'package:dartz/dartz.dart';
import 'package:dopamine_detox_app/core/constants/app_constants.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/usecases/calculate_score.dart';
import '../../domain/repositories/gamification_repository.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/repositories/log_repository.dart';


class CheckAndUpdateStreakUseCase {
  final GamificationRepository gamificationRepository;
  final LogRepository logRepository;

  CheckAndUpdateStreakUseCase(
    this.gamificationRepository,
    this.logRepository,
  );

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Finalizes the previous completed day.
  ///
  /// Important:
  /// - Today is still in progress, so it should not award streak/XP.
  /// - Yesterday is completed, so it can be finalized safely.
  /// - First run does not award fake streak.
  /// - Missed multiple days reset streak before checking yesterday.
  Future<Either<String, StreakUpdateResult>> call() async {
    try {
      final now = DateTime.now();
      final today = _dateOnly(now);
      final yesterday = today.subtract(const Duration(days: 1));

      final gamificationResult = await gamificationRepository.getGamification();

      return await gamificationResult.fold(
        (error) async => Left(error),
        (gamification) async {
          int currentStreak = gamification.currentStreak;
          final lastCheckDate = gamification.lastStreakCheckDate == null
              ? null
              : _dateOnly(gamification.lastStreakCheckDate!);

          // First run:
          // Do not reward yesterday because we don't know if user was active.
          // Mark yesterday as checked so tomorrow can process today properly.
          if (lastCheckDate == null) {
            await gamificationRepository.updateStreak(
              currentStreak,
              checkDate: yesterday,
            );

            return Right(
              StreakUpdateResult(
                newStreak: currentStreak,
                xpAwarded: 0,
                wasPerfectDay: false,
                todayScore: AppConstants.maxDopamineScore,
              ),
            );
          }

          // Already processed yesterday or newer.
          if (!lastCheckDate.isBefore(yesterday)) {
            return Right(
              StreakUpdateResult(
                newStreak: currentStreak,
                xpAwarded: 0,
                wasPerfectDay: false,
                todayScore: AppConstants.maxDopamineScore,
              ),
            );
          }

          // If user missed more than one completed day, do not create fake streak.
          // Reset first, then only process yesterday.
          final missedDays = yesterday.difference(lastCheckDate).inDays;
          if (missedDays > 1) {
            currentStreak = 0;
          }

          final logsResult = await logRepository.getLogsForDate(yesterday);

          return await logsResult.fold(
            (error) async => Left(error),
            (yesterdayLogs) async {
              final score = CalculateScore.calculate(yesterdayLogs);
              final isValid = CalculateScore.isStreakValid(score);
              final isPerfect = CalculateScore.isPerfectDay(score);

              int newStreak = currentStreak;
              int xpAwarded = 0;

              if (isValid) {
                newStreak = currentStreak + 1;

                if (isPerfect) {
                  xpAwarded += AppConstants.xpPerfectDay;
                } else {
                  xpAwarded += AppConstants.xpGoodDay;
                }

                if (currentStreak > 0) {
                  xpAwarded += AppConstants.xpStreakMaintain;
                }
              } else {
                newStreak = 0;
              }

              await gamificationRepository.updateStreak(
                newStreak,
                checkDate: yesterday,
              );

              if (xpAwarded > 0) {
                await gamificationRepository.addXP(xpAwarded);
              }

              return Right(
                StreakUpdateResult(
                  newStreak: newStreak,
                  xpAwarded: xpAwarded,
                  wasPerfectDay: isPerfect,
                  todayScore: score,
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      return Left(e.toString());
    }
  }
}

class StreakUpdateResult {
  final int newStreak;
  final int xpAwarded;
  final bool wasPerfectDay;

  /// This is the finalized previous day score.
  /// Keeping name todayScore to avoid changing too many files now.
  final int todayScore;

  StreakUpdateResult({
    required this.newStreak,
    required this.xpAwarded,
    required this.wasPerfectDay,
    required this.todayScore,
  });
}