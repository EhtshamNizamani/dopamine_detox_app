import '../../features/activity_log/domain/entities/log_entry_entity.dart';
import '../constants/app_constants.dart';

class CalculateStreak {
  static int calculate(List<DateTime> logDates) {
    if (logDates.isEmpty) return 0;
    
    final uniqueDates = logDates.map((d) => DateTime(d.year, d.month, d.day)).toSet().toList();
    uniqueDates.sort((a, b) => b.compareTo(a));
    
    int streak = 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (!uniqueDates.contains(today)) return 0;
    
    streak = 1;
    DateTime checkDate = today.subtract(const Duration(days: 1));
    
    while (uniqueDates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    return streak;
  }
  
  static int calculateScore(List<LogEntryEntity> todayLogs) {
    if (todayLogs.isEmpty) return AppConstants.maxDopamineScore;
    
    int totalIntensity = todayLogs.fold(0, (sum, log) => sum + log.intensity);
    int score = AppConstants.maxDopamineScore - (totalIntensity * 3);
    return score.clamp(AppConstants.minDopamineScore, AppConstants.maxDopamineScore);
  }
}