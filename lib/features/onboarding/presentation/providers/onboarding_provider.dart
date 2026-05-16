import 'package:dopamine_detox_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';

class OnboardingViewModel extends ChangeNotifier {
  int _currentPage = 0;
  int get currentPage => _currentPage;

  void updatePage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    // SharedPreferences mein flag set karo
    final prefs = sl<SharedPreferences>();
    await prefs.setBool(AppConstants.keyOnboardingCompleted, true);
  }
}