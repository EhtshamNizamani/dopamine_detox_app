import 'package:dopamine_detox_app/features/gamification/domain/entities/gamification.dart';
import 'package:dopamine_detox_app/features/gamification/domain/usecases/add_xp.dart';
import 'package:dopamine_detox_app/features/gamification/domain/usecases/get_gamification.dart';
import 'package:flutter/material.dart';

class GamificationViewModel extends ChangeNotifier {
  final GetGamificationUseCase getGamification;
  final AddXPUseCase addXP;

  GamificationViewModel({
    required this.getGamification,
    required this.addXP,
  });

  GamificationEntity? _gamification;
  bool _isLoading = false;
  String? _error;

  GamificationEntity? get gamification => _gamification;
  bool get isLoading => _isLoading;
  String? get error => _error;

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
        loadGamification(); // refresh after adding
        return true;
      },
    );
  }
}