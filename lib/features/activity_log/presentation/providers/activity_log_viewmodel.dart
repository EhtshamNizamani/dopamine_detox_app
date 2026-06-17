import 'package:dopamine_detox_app/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/log_entry_entity.dart';
import '../../domain/usecases/add_log_usecase.dart';
import '../../domain/usecases/get_today_logs.dart';

class ActivityLogViewModel extends ChangeNotifier {
  final AddLogUseCase addLogUseCase;
  final GetTodayLogsUseCase getTodayLogs;

  ActivityLogViewModel({
    required this.addLogUseCase,
    required this.getTodayLogs,
  });

  bool _isLoading = false;
  String? _error;
  final List<String> _newlyUnlockedBadges = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get newlyUnlockedBadges => _newlyUnlockedBadges;

  Future<(int currentScore, int projectedScore)> calculateProjectedScore(
    int intensity,
  ) async {
    final todayResult = await getTodayLogs();
    final todayLogs = todayResult.fold((l) => <LogEntryEntity>[], (r) => r);

    int currentPenalty = 0;

    for (final log in todayLogs) {
      switch (log.intensity) {
        case 1:
          currentPenalty += AppConstants.lowIntensityPenalty;
          break;
        case 2:
          currentPenalty += AppConstants.mediumIntensityPenalty;
          break;
        case 3:
          currentPenalty += AppConstants.highIntensityPenalty;
          break;
      }
    }

    final currentScore = (AppConstants.maxDopamineScore - currentPenalty)
        .clamp(
          AppConstants.minDopamineScore,
          AppConstants.maxDopamineScore,
        );

    int additionalPenalty = 0;

    switch (intensity) {
      case 1:
        additionalPenalty = AppConstants.lowIntensityPenalty;
        break;
      case 2:
        additionalPenalty = AppConstants.mediumIntensityPenalty;
        break;
      case 3:
        additionalPenalty = AppConstants.highIntensityPenalty;
        break;
    }

    final projectedScore = (currentScore - additionalPenalty).clamp(
      AppConstants.minDopamineScore,
      AppConstants.maxDopamineScore,
    );

    return (currentScore, projectedScore);
  }

  Future<bool> logActivity(String activityName, int intensity) async {
    _isLoading = true;
    _error = null;
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
    _newlyUnlockedBadges.clear();
    notifyListeners();
  }
}