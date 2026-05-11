import 'package:dartz/dartz.dart';
import 'package:dopamine_detox_app/features/settings/domain/entities/settings.dart';
import 'package:dopamine_detox_app/features/settings/domain/repositories/settings_repository.dart';

class GetSettings {
  final SettingsRepository repository;
  GetSettings(this.repository);
  Future<Either<String, SettingsEntity>> call() => repository.getSettings();
}