import 'package:dopamine_detox_app/core/constants/app_constants.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/entities/log_entry_entity.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/usecases/calculate_streak.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/usecases/get_recent_logs.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/usecases/get_streak.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/usecases/get_today_logs.dart';
import 'package:flutter/material.dart';

class DashboardViewModel extends ChangeNotifier {
  final GetTodayLogsUseCase getTodayLogs;
  final GetRecentLogsUseCase getRecentLogs;
  final GetStreakUseCase getStreak;

  DashboardViewModel({
    required this.getTodayLogs,
    required this.getRecentLogs,
    required this.getStreak,
  });

  List<LogEntryEntity> _todayLogs = [];
  List<LogEntryEntity> _recentLogs = [];
  int _streak = 0;
  int _dopamineScore = AppConstants.maxDopamineScore;
  bool _isLoading = false;
  String? _error;

  List<LogEntryEntity> get todayLogs => _todayLogs;
  List<LogEntryEntity> get recentLogs => _recentLogs;
  int get streak => _streak;
  int get dopamineScore => _dopamineScore;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Fetch today's logs
    final todayResult = await getTodayLogs();
    await todayResult.fold(
      (error) => _error = error,
      (logs) {
        _todayLogs = logs;
        _dopamineScore = CalculateStreak.calculateScore(logs);
      },
    );

    // Fetch recent logs (last 10)
    final recentResult = await getRecentLogs(limit: 10);
    recentResult.fold(
      (error) => _error = _error ?? error,
      (logs) => _recentLogs = logs,
    );

    // Fetch streak
    final streakResult = await getStreak();
    streakResult.fold(
      (error) => _error = _error ?? error,
      (streak) => _streak = streak,
    );

    _isLoading = false;
    notifyListeners();
  }
}