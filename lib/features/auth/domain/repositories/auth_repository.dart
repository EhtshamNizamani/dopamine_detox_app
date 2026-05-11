import 'package:dartz/dartz.dart';  // add dartz in pubspec for Either
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<String, UserEntity>> signInAnonymously();
  Future<void> signOut();
  Stream<UserEntity?> get authStateChanges;
}