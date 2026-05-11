import 'package:dopamine_detox_app/features/settings/domain/entities/settings.dart';
import 'package:dopamine_detox_app/features/settings/domain/usecases/get_settings.dart';
import 'package:dopamine_detox_app/features/settings/domain/usecases/reset_all_data.dart';
import 'package:dopamine_detox_app/features/settings/domain/usecases/update_notifications.dart';
import 'package:flutter/material.dart';

class SettingsViewModel extends ChangeNotifier {
  final GetSettings getSettings;
  final UpdateNotifications updateNotifications;
  final ResetAllData resetAllData;

  SettingsViewModel({
    required this.getSettings,
    required this.updateNotifications,
    required this.resetAllData,
  });

  SettingsEntity? _settings;
  bool _isLoading = false;
  String? _error;

  SettingsEntity? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();
    final result = await getSettings();
    result.fold(
      (error) => _error = error,
      (settings) => _settings = settings,
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> toggleNotifications(bool value) async {
    final result = await updateNotifications(value);
    return result.fold(
      (error) {
        _error = error;
        notifyListeners();
        return false;
      },
      (_) {
        _settings = SettingsEntity(notificationsEnabled: value);
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> resetData() async {
    _isLoading = true;
    notifyListeners();
    final result = await resetAllData();
    _isLoading = false;
    return result.fold(
      (error) {
        _error = error;
        notifyListeners();
        return false;
      },
      (_) {
        _settings = SettingsEntity(notificationsEnabled: true); // default after reset
        notifyListeners();
        return true;
      },
    );
  }
}