import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class CheckAuthStatus {
  final AuthRepository repository;
  
  CheckAuthStatus(this.repository);
  
  Stream<Either<String, UserEntity?>> call() {
    return repository.authStateChanges.map((user) {
      return Right(user);
    });
  }
}