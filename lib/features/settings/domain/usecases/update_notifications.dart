import 'package:dartz/dartz.dart';
import '../repositories/settings_repository.dart';

class UpdateNotifications {
  final SettingsRepository repository;
  UpdateNotifications(this.repository);
  Future<Either<String, void>> call(bool enabled) => repository.updateNotifications(enabled);
}