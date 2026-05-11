import 'package:dartz/dartz.dart';
import '../entities/log_entry_entity.dart';

abstract class LogRepository {
  Future<Either<String, void>> addLog(LogEntryEntity log);
  Future<Either<String, List<LogEntryEntity>>> getLogsForDate(DateTime date);
  Future<Either<String, List<LogEntryEntity>>> getRecentLogs({int limit = 10});
}