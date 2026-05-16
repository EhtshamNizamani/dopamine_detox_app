import 'package:dartz/dartz.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/entities/log_entry_entity.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/repositories/log_repository.dart';
import 'calculate_streak.dart';

class GetStreakUseCase {
  final LogRepository logRepository;

  GetStreakUseCase(this.logRepository);

  Future<Either<String, int>> call() async {
    // Fetch last 60 days of logs for streak calculation
    final result = await logRepository.getRecentLogs(limit: 500);
    return result.fold(
      (error) => Left(error),
      (logs) {
        // Group logs by date
        final dailyLogs = <DateTime, List<LogEntryEntity>>{};
        for (final log in logs) {
          final date = DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
          dailyLogs.putIfAbsent(date, () => []);
          dailyLogs[date]!.add(log);
        }
        final streak = CalculateStreak.calculate(dailyLogs);
        return Right(streak);
      },
    );
  }

  /// Get detailed streak info (dates and scores)
  Future<Either<String, StreakInfo>> getStreakInfo() async {
    final result = await logRepository.getRecentLogs(limit: 500);
    return result.fold(
      (error) => Left(error),
      (logs) {
        final dailyLogs = <DateTime, List<LogEntryEntity>>{};
        for (final log in logs) {
          final date = DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
          dailyLogs.putIfAbsent(date, () => []);
          dailyLogs[date]!.add(log);
        }
        
        final streak = CalculateStreak.calculate(dailyLogs);
        final streakDates = CalculateStreak.getStreakDates(dailyLogs);
        
        return Right(StreakInfo(
          currentStreak: streak,
          streakDates: streakDates,
        ));
      },
    );
  }
}

class StreakInfo {
  final int currentStreak;
  final List<DateTime> streakDates;

  StreakInfo({required this.currentStreak, required this.streakDates});
}