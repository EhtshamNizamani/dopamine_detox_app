import 'package:dopamine_detox_app/features/gamification/domain/entities/gamification.dart';
import 'package:dopamine_detox_app/features/gamification/domain/usecases/add_xp.dart';
import 'package:dopamine_detox_app/features/gamification/domain/usecases/check_daily_open.dart';
import 'package:dopamine_detox_app/features/gamification/domain/usecases/get_gamification.dart';
import 'package:flutter/material.dart';

class GamificationViewModel extends ChangeNotifier {
  final GetGamificationUseCase getGamification;
  final AddXPUseCase addXP;
  final CheckDailyOpenUseCase checkDailyOpen;

  GamificationViewModel({
    required this.getGamification,
    required this.addXP,
    required this.checkDailyOpen,
  });

  GamificationEntity? _gamification;
  bool _isLoading = false;
  String? _error;
  bool _dailyXPAwarded = false;

  GamificationEntity? get gamification => _gamification;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get dailyXPAwarded => _dailyXPAwarded;

  Future<void> loadGamification() async {
    _isLoading = true;
    notifyListeners();
    
    final result = await getGamification();
    result.fold(
      (error) => _error = error,
      (data) => _gamification = data,
    );
    
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addXPAndRefresh(int xp) async {
    final result = await addXP(xp);
    return result.fold(
      (error) {
        _error = error;
        notifyListeners();
        return false;
      },
      (_) {
        loadGamification();
        return true;
      },
    );
  }

  /// Call this when app opens to check daily XP
  Future<void> checkDailyOpenXP() async {
    final result = await checkDailyOpen();
    result.fold(
      (error) => debugPrint('Daily open check error: $error'),
      (wasAwarded) {
        _dailyXPAwarded = wasAwarded;
        if (wasAwarded) {
          loadGamification(); // Refresh to show new XP
        }
      },
    );
  }
}