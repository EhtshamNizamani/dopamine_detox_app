import 'package:dartz/dartz.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/repositories/log_repository.dart';

class GetTotalLogsCountUseCase {
  final LogRepository repository;
  GetTotalLogsCountUseCase(this.repository);
  Future<Either<String, int>> call() => repository.getTotalLogsCount();
}