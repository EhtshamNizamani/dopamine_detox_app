import 'package:dartz/dartz.dart';
import '../entities/log_entry_entity.dart';
import '../repositories/log_repository.dart';

class AddLogUseCase {
  final LogRepository repository;

  AddLogUseCase(this.repository);

  Future<Either<String, void>> call(LogEntryEntity log) async {
    return await repository.addLog(log);
  }
}