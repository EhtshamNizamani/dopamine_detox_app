import 'package:dopamine_detox_app/features/activity_log/domain/entities/log_entry_entity.dart';

import '../../../../core/constants/app_constants.dart';

class CalculateStreak {
  /// Pass list of dates where user logged ANY activity (only dates matter)
  static int calculate(List<DateTime> logDates) {
    if (logDates.isEmpty) return 0;
    
    // Get unique dates only (no time)
    final uniqueDates = logDates.map((d) => DateTime(d.year, d.month, d.day)).toSet().toList();
    uniqueDates.sort((a, b) => b.compareTo(a)); // descending
    
    int streak = 0;
    DateTime current = DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    
    // Check if logged today
    if (!uniqueDates.contains(today)) return 0;
    
    streak = 1;
    DateTime checkDate = today.subtract(const Duration(days: 1));
    
    while (uniqueDates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    
    return streak;
  }
  
  /// Calculate dopamine score (0-100) based on:
  /// - Number of logs today (more logs = lower score)
  /// - Intensity sum (higher intensity = lower score)
  static int calculateScore(List<LogEntryEntity> todayLogs) {
    if (todayLogs.isEmpty) return AppConstants.maxDopamineScore;
    
    int totalIntensity = todayLogs.fold(0, (sum, log) => sum + log.intensity);
    // Maximum possible intensity per day: 10 logs * 3 = 30
    // Score = max(0, 100 - (totalIntensity * 3))
    int score = AppConstants.maxDopamineScore - (totalIntensity * 3);
    return score.clamp(AppConstants.minDopamineScore, AppConstants.maxDopamineScore);
  }
}