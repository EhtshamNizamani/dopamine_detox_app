import 'package:dartz/dartz.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/repositories/log_repository.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/usecases/calculate_streak.dart';

class GetStreakUseCase {
  final LogRepository logRepository;

  GetStreakUseCase(this.logRepository);

  Future<Either<String, int>> call() async {
    // Fetch all logs (we need all logs to check daily presence). Better to have a method for all logs?
    // For MVP, we can fetch logs for last 30 days and check streak.
    final result = await logRepository.getRecentLogs(limit: 100);
    return result.fold(
      (error) => Left(error),
      (logs) {
        final logDates = logs.map((log) => log.timestamp).toList();
        final streak = CalculateStreak.calculate(logDates);
        return Right(streak);
      },
    );
  }
}