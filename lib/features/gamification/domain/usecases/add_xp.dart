import 'package:dartz/dartz.dart';
import '../repositories/gamification_repository.dart';

class AddXPUseCase {
  final GamificationRepository repository;
  AddXPUseCase(this.repository);
  Future<Either<String, void>> call(int xp) => repository.addXP(xp);
}