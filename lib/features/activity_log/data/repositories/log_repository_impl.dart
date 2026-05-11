import 'package:dartz/dartz.dart';
import '../../domain/entities/log_entry_entity.dart';
import '../../domain/repositories/log_repository.dart';
import '../datasources/log_local_datasource.dart';
import '../models/log_entry_model.dart';

class LogRepositoryImpl implements LogRepository {
  final LogLocalDataSource dataSource;

  LogRepositoryImpl(this.dataSource);

  @override
  Future<Either<String, void>> addLog(LogEntryEntity log) async {
    try {
      final model = LogEntryModel(
        activityName: log.activityName,
        intensity: log.intensity,
        timestamp: log.timestamp,
      );
      await dataSource.insertLog(model);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<LogEntryEntity>>> getLogsForDate(DateTime date) async {
    try {
      final logs = await dataSource.getLogsForDate(date);
      return Right(logs);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<LogEntryEntity>>> getRecentLogs({int limit = 10}) async {
    try {
      final logs = await dataSource.getRecentLogs(limit: limit);
      return Right(logs);
    } catch (e) {
      return Left(e.toString());
    }
  }
}