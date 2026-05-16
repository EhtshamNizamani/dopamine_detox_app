import 'package:dopamine_detox_app/features/activity_log/domain/entities/log_entry_entity.dart';
import 'calculate_score.dart';

class CalculateStreak {
  /// Calculate streak: consecutive days (from today backwards) with score >= 80
  /// Stops at the earliest date that has ANY log (usse pehle count nahi hoga)
  static int calculate(Map<DateTime, List<LogEntryEntity>> dailyLogs) {
    if (dailyLogs.isEmpty) return 0;

    // Get earliest date that has logs
    final sortedDates = dailyLogs.keys.toList()..sort();
    final earliestLogDate = DateTime(
      sortedDates.first.year,
      sortedDates.first.month,
      sortedDates.first.day,
    );

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    int streak = 0;
    DateTime checkDate = todayDate;

    while (true) {
      // 🛑 STOP: Don't go before the user's first log date
      if (checkDate.isBefore(earliestLogDate)) break;

      final logsForDate = dailyLogs[checkDate] ?? [];
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

  /// Get all dates that had a valid streak (score >= 80)
  static List<DateTime> getStreakDates(Map<DateTime, List<LogEntryEntity>> dailyLogs) {
    final validDates = <DateTime>[];
    if (dailyLogs.isEmpty) return validDates;

    final sortedDates = dailyLogs.keys.toList()..sort();
    final earliestLogDate = DateTime(
      sortedDates.first.year,
      sortedDates.first.month,
      sortedDates.first.day,
    );

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    DateTime checkDate = todayDate;

    while (true) {
      if (checkDate.isBefore(earliestLogDate)) break;

      final logs = dailyLogs[checkDate] ?? [];
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

  static bool wasPerfectDay(DateTime date, Map<DateTime, List<LogEntryEntity>> dailyLogs) {
    final logs = dailyLogs[DateTime(date.year, date.month, date.day)] ?? [];
    return CalculateScore.isPerfectDay(CalculateScore.calculate(logs));
  }
}
