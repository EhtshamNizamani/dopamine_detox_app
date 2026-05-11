import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInAnonymously {
  final AuthRepository repository;
  
  SignInAnonymously(this.repository);
  
  Future<Either<String, UserEntity>> call() async {
    return await repository.signInAnonymously();
  }
}