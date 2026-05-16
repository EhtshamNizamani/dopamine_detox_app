import 'package:dopamine_detox_app/core/constants/app_constants.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/entities/log_entry_entity.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/usecases/calculate_score.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/usecases/get_recent_logs.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/usecases/get_streak.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/usecases/get_today_logs.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/usecases/get_total_logs_count.dart';
import 'package:dopamine_detox_app/features/gamification/domain/entities/gamification.dart';
import 'package:dopamine_detox_app/features/gamification/domain/usecases/check_and_update_streak.dart';
import 'package:dopamine_detox_app/features/gamification/domain/usecases/get_gamification.dart';
import 'package:dopamine_detox_app/features/gamification/domain/usecases/unlock_badges.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DashboardViewModel extends ChangeNotifier {
  final GetTodayLogsUseCase getTodayLogs;
  final GetRecentLogsUseCase getRecentLogs;
  final GetStreakUseCase getStreak;
  final GetGamificationUseCase getGamification;
  final CheckAndUpdateStreakUseCase checkStreak;
  final UnlockBadgesUseCase unlockBadges;
  final GetTotalLogsCountUseCase getTotalLogsCount;

  DashboardViewModel({
    required this.getTodayLogs,
    required this.getRecentLogs,
    required this.getStreak,
    required this.getGamification,
    required this.checkStreak,
    required this.unlockBadges,
    required this.getTotalLogsCount,
  });

  List<LogEntryEntity> _todayLogs = [];
  List<LogEntryEntity> _recentLogs = [];
  int _streak = 0;
  int _dopamineScore = AppConstants.maxDopamineScore;
  GamificationEntity? _gamification;
  bool _isLoading = false;
  String? _error;
  List<String> _newlyUnlockedBadges = [];
  int _lastXPAwarded = 0;

  int get lastXPAwarded => _lastXPAwarded;
  List<LogEntryEntity> get todayLogs => _todayLogs;
  List<LogEntryEntity> get recentLogs => _recentLogs;
  int get streak => _streak;
  int get dopamineScore => _dopamineScore;
  GamificationEntity? get gamification => _gamification;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get newlyUnlockedBadges => _newlyUnlockedBadges;

Future<void> loadDashboardData() async {
  _isLoading = true;
  _error = null;
  _newlyUnlockedBadges = [];
  _lastXPAwarded = 0;  // Reset har load pe
  notifyListeners();

  try {
    print('DashboardViewModel: Starting to load dashboard data...');

    // 1. Fetch today's logs
    final todayResult = await getTodayLogs();
    todayResult.fold((error) => _error = error, (logs) {
      _todayLogs = logs;
      _dopamineScore = CalculateScore.calculate(logs);
      print(' DashboardViewModel: Today logs loaded. Dopamine score: $_dopamineScore');
      print(_todayLogs.map((log) => ' - ${log.activityName} (Intensity: ${log.intensity})').join('\n'));
    });
    print('DashboardViewModel: Today logs loaded. #');

    // 2. Fetch recent logs
    final recentResult = await getRecentLogs(limit: 10);
    recentResult.fold(
      (error) => _error = _error ?? error,
      (logs) => _recentLogs = logs,
    );
    print('DashboardViewModel: Recent logs loaded.');

    // 3. Calculate streak from logs (score >= 80)
    final streakResult = await getStreak();
    streakResult.fold(
      (error) => _error = _error ?? error,
      (streak) => _streak = streak,
    );
    print('DashboardViewModel: Streak calculated: $_streak days.');

    // 4. Award daily XP (idempotent) + Save XP amount
    final streakUpdateResult = await checkStreak(_todayLogs);
    streakUpdateResult.fold(
      (error) => debugPrint('Streak XP error: $error'),
      (result) {
        _lastXPAwarded = result.xpAwarded;  // ← XP save karo (SIRF EK BAAR)
        if (result.xpAwarded > 0) {
          debugPrint('Daily XP awarded: ${result.xpAwarded}');
        }
      },
    );
    print('DashboardViewModel: Streak XP updated. Last XP: $_lastXPAwarded');

    // 5. Load gamification data
    final gamificationResult = await getGamification();
    gamificationResult.fold(
      (error) => _error = _error ?? error,
      (data) => _gamification = data,
    );
    print('DashboardViewModel: Gamification data loaded. Level: ${_gamification?.level}, XP: ${_gamification}');

    // 6. Check and unlock badges
    if (_gamification != null) {
      final totalCountResult = await getTotalLogsCount();
      final totalCount = totalCountResult.fold((l) => 0, (r) => r);

      final badgeResult = await unlockBadges(
        currentStreak: _streak,
        currentLevel: _gamification!.level,
        todayScore: _dopamineScore,
        totalLogsCount: totalCount,
      );

      print('DashboardViewModel: Checking for new badges...');
      badgeResult.fold((error) => debugPrint('Badge unlock error: $error'), (newBadges) {
        _newlyUnlockedBadges = newBadges;
        if (newBadges.isNotEmpty) {
          debugPrint('Dashboard: New badges unlocked: $newBadges');
        }
      });
    }

    print('DashboardViewModel: All data loaded.');
  } catch (e, stackTrace) {
    _error = 'Unexpected error: $e';
    debugPrint('Dashboard load error: $e');
    debugPrint(stackTrace.toString());
  } finally {
    _isLoading = false;
    notifyListeners();
    print('DashboardViewModel: Loading finished.');
  }
}

  void clearNewBadges() {
    _newlyUnlockedBadges = [];
    notifyListeners();
  }

  String getScoreLabel() {
    if (_dopamineScore >= 90) return 'Excellent';
    if (_dopamineScore >= 80) return 'Good';
    if (_dopamineScore >= 60) return 'Average';
    return 'Needs Work';
  }

  Color getScoreColor() {
    if (_dopamineScore >= 90) return Colors.green;
    if (_dopamineScore >= 80) return Colors.lightGreen;
    if (_dopamineScore >= 60) return Colors.orange;
    return Colors.red;
  }

  void clearLastXP() {
  _lastXPAwarded = 0;
  notifyListeners();
}

}

