import 'package:dartz/dartz.dart';
import '../entities/log_entry_entity.dart';
import '../repositories/log_repository.dart';

class GetRecentLogsUseCase {
  final LogRepository repository;

  GetRecentLogsUseCase(this.repository);

  Future<Either<String, List<LogEntryEntity>>> call({int limit = 10}) async {
    return await repository.getRecentLogs(limit: limit);
  }
}