import 'package:dartz/dartz.dart';
import '../repositories/settings_repository.dart';

class ResetAllData {
  final SettingsRepository repository;
  ResetAllData(this.repository);
  Future<Either<String, void>> call() => repository.resetAllData();
}