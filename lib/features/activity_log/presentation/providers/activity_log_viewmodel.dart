import 'package:dopamine_detox_app/core/constants/app_constants.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/usecases/get_today_logs.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/usecases/get_total_logs_count.dart';
import 'package:dopamine_detox_app/features/gamification/domain/usecases/unlock_badges.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/log_entry_entity.dart';
import '../../domain/usecases/add_log_usecase.dart';

class ActivityLogViewModel extends ChangeNotifier {
  final AddLogUseCase addLogUseCase;
  final GetTotalLogsCountUseCase getTotalLogsCount;
  final UnlockBadgesUseCase unlockBadges;
  final GetTodayLogsUseCase getTodayLogs; // NEW: for current score calc

  ActivityLogViewModel({
    required this.addLogUseCase,
    required this.getTotalLogsCount,
    required this.unlockBadges,
    required this.getTodayLogs, // NEW
  });

  bool _isLoading = false;
  String? _error;
  List<String> _newlyUnlockedBadges = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get newlyUnlockedBadges => _newlyUnlockedBadges;

  /// Calculate what the score would be if user logs this trigger NOW
  /// Returns (currentScore, projectedScore)
  Future<(int currentScore, int projectedScore)> calculateProjectedScore(int intensity) async {
    // 1. Get today's current logs
    final todayResult = await getTodayLogs();
    final todayLogs = todayResult.fold((l) => <LogEntryEntity>[], (r) => r);

    // 2. Calculate current score
    int currentPenalty = 0;
    for (final log in todayLogs) {
      switch (log.intensity) {
        case 1: currentPenalty += AppConstants.lowIntensityPenalty; break;
        case 2: currentPenalty += AppConstants.mediumIntensityPenalty; break;
        case 3: currentPenalty += AppConstants.highIntensityPenalty; break;
      }
    }
    final currentScore = (AppConstants.maxDopamineScore - currentPenalty)
        .clamp(AppConstants.minDopamineScore, AppConstants.maxDopamineScore);

    // 3. Calculate projected score with new log
    int additionalPenalty = 0;
    switch (intensity) {
      case 1: additionalPenalty = AppConstants.lowIntensityPenalty; break;
      case 2: additionalPenalty = AppConstants.mediumIntensityPenalty; break;
      case 3: additionalPenalty = AppConstants.highIntensityPenalty; break;
    }
    final projectedScore = (currentScore - additionalPenalty)
        .clamp(AppConstants.minDopamineScore, AppConstants.maxDopamineScore);

    return (currentScore, projectedScore);
  }

  Future<bool> logActivity(String activityName, int intensity) async {
    _isLoading = true;
    _newlyUnlockedBadges = [];
    notifyListeners();

    try {
      final log = LogEntryEntity(
        activityName: activityName,
        intensity: intensity,
        timestamp: DateTime.now(),
      );

      final result = await addLogUseCase(log);
      
      if (result.isLeft()) {
        _error = result.fold((l) => l, (r) => null);
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final countResult = await getTotalLogsCount();
      final totalLogs = countResult.fold((l) => 0, (r) => r);

      final badgeResult = await unlockBadges(
        currentStreak: 0,
        currentLevel: 1,
        todayScore: 0,
        totalLogsCount: totalLogs,
      );

      badgeResult.fold(
        (error) => debugPrint('Badge check error: $error'),
        (newBadges) {
          _newlyUnlockedBadges = newBadges;
          if (newBadges.isNotEmpty) {
            debugPrint('New badges unlocked: $newBadges');
          }
        },
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearNewBadges() {
    _newlyUnlockedBadges = [];
    notifyListeners();
  }
}
