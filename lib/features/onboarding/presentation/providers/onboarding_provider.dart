import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';

class OnboardingViewModel extends ChangeNotifier {
  final SharedPreferences prefs;
  
  OnboardingViewModel(this.prefs);
  
  int _currentPage = 0;
  int get currentPage => _currentPage;
  
  void updatePage(int page) {
    _currentPage = page;
    notifyListeners();
  }
  
  Future<void> completeOnboarding() async {
    await prefs.setBool(AppConstants.keyOnboardingCompleted, true);
  }
  
  bool isOnboardingCompleted() {
    return prefs.getBool(AppConstants.keyOnboardingCompleted) ?? false;
  }
}