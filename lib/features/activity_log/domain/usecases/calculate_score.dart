import '../../../../core/constants/app_constants.dart';
import '../entities/log_entry_entity.dart';

class CalculateScore {
  /// Calculate dopamine score (0-100) based on intensity penalties
  /// Low = -3, Medium = -7, High = -15
  static int calculate(List<LogEntryEntity> todayLogs) {
    if (todayLogs.isEmpty) return AppConstants.maxDopamineScore;

    int totalPenalty = 0;
    for (final log in todayLogs) {
      switch (log.intensity) {
        case 1:
          totalPenalty += AppConstants.lowIntensityPenalty;
          break;
        case 2:
          totalPenalty += AppConstants.mediumIntensityPenalty;
          break;
        case 3:
          totalPenalty += AppConstants.highIntensityPenalty;
          break;
      }
    }

    int score = AppConstants.maxDopamineScore - totalPenalty;
    return score.clamp(AppConstants.minDopamineScore, AppConstants.maxDopamineScore);
  }

  /// Check if score qualifies for streak continuation
  static bool isStreakValid(int score) => score >= AppConstants.streakThreshold;

  /// Check if it's a perfect day (score = 100)
  static bool isPerfectDay(int score) => score == AppConstants.maxDopamineScore;
}