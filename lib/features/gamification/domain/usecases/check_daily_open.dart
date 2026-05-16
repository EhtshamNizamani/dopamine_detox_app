import 'package:dartz/dartz.dart';
import '../../domain/repositories/gamification_repository.dart';

class CheckDailyOpenUseCase {
  final GamificationRepository repository;

  CheckDailyOpenUseCase(this.repository);

  /// Returns true if XP was awarded for daily open
  Future<Either<String, bool>> call() async {
    return await repository.checkDailyOpenXP();
  }
}