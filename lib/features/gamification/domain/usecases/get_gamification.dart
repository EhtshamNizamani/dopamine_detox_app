import 'package:dartz/dartz.dart';
import 'package:dopamine_detox_app/features/gamification/domain/entities/gamification.dart';
import 'package:dopamine_detox_app/features/gamification/domain/repositories/gamification_repository.dart';

class GetGamificationUseCase {
  final GamificationRepository repository;
  GetGamificationUseCase(this.repository);
  Future<Either<String, GamificationEntity>> call() => repository.getGamification();
}