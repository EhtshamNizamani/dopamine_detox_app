import 'package:dartz/dartz.dart';
import 'package:dopamine_detox_app/features/settings/data/datasources/settings_local_ds.dart';
import 'package:dopamine_detox_app/features/settings/domain/entities/settings.dart';
import 'package:dopamine_detox_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:sqflite/sqflite.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource dataSource;
  final Database db;

  SettingsRepositoryImpl(this.dataSource, this.db);

  @override
  Future<Either<String, SettingsEntity>> getSettings() async {
    try {
      final enabled = dataSource.notificationsEnabled;
      return Right(SettingsEntity(notificationsEnabled: enabled));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> updateNotifications(bool enabled) async {
    try {
      await dataSource.setNotificationsEnabled(enabled);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> resetAllData() async {
    try {
      // Clear SharedPreferences (except maybe first-time flags? clear all)
      await dataSource.clearAllData();
      // Delete all rows from activity_logs table
      await db.delete('activity_logs');
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}