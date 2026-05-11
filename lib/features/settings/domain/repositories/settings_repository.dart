import 'package:dartz/dartz.dart';
import 'package:dopamine_detox_app/features/settings/domain/entities/settings.dart';

abstract class SettingsRepository {
  Future<Either<String, SettingsEntity>> getSettings();
  Future<Either<String, void>> updateNotifications(bool enabled);
  Future<Either<String, void>> resetAllData();  // clears logs, resets onboarding?
}