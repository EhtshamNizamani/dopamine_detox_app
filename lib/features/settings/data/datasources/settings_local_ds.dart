import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';

class SettingsLocalDataSource {
  final SharedPreferences prefs;

  SettingsLocalDataSource(this.prefs);

  bool get notificationsEnabled {
    return prefs.getBool(AppConstants.keyNotificationEnabled) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await prefs.setBool(AppConstants.keyNotificationEnabled, enabled);
  }

  Future<void> clearAllData() async {
    await prefs.clear();  // clears onboarding flag too
    // Also need to clear SQLite? We'll handle in repository.
  }
}