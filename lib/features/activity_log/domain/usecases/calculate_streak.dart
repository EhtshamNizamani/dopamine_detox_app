import 'package:dopamine_detox_app/features/activity_log/domain/entities/log_entry_entity.dart';
import 'calculate_score.dart';

class CalculateStreak {
  /// Legacy helper.
  ///
  /// Important:
  /// This only counts dates that actually exist in dailyLogs.
  /// Missing dates will break the streak instead of becoming fake perfect days.
  static int calculate(Map<DateTime, List<LogEntryEntity>> dailyLogs) {
    if (dailyLogs.isEmpty) return 0;

    final today = DateTime.now();
    DateTime checkDate = DateTime(today.year, today.month, today.day);

    int streak = 0;

    while (true) {
      if (!dailyLogs.containsKey(checkDate)) {
        break;
      }

      final logsForDate = dailyLogs[checkDate]!;
      final score = CalculateScore.calculate(logsForDate);

      if (CalculateScore.isStreakValid(score)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  static List<DateTime> getStreakDates(
    Map<DateTime, List<LogEntryEntity>> dailyLogs,
  ) {
    final validDates = <DateTime>[];

    if (dailyLogs.isEmpty) return validDates;

    final today = DateTime.now();
    DateTime checkDate = DateTime(today.year, today.month, today.day);

    while (true) {
      if (!dailyLogs.containsKey(checkDate)) {
        break;
      }

      final logs = dailyLogs[checkDate]!;
      final score = CalculateScore.calculate(logs);

      if (CalculateScore.isStreakValid(score)) {
        validDates.add(checkDate);
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return validDates;
  }

  static bool wasPerfectDay(
    DateTime date,
    Map<DateTime, List<LogEntryEntity>> dailyLogs,
  ) {
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (!dailyLogs.containsKey(dateOnly)) {
      return false;
    }

    final logs = dailyLogs[dateOnly]!;
    return CalculateScore.isPerfectDay(CalculateScore.calculate(logs));
  }
}
