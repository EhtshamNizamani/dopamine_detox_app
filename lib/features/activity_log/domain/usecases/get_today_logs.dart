import 'package:dartz/dartz.dart';
import '../entities/log_entry_entity.dart';
import '../repositories/log_repository.dart';

class GetTodayLogsUseCase {
  final LogRepository repository;

  GetTodayLogsUseCase(this.repository);

  Future<Either<String, List<LogEntryEntity>>> call() async {
    return await repository.getLogsForDate(DateTime.now());
  }
}