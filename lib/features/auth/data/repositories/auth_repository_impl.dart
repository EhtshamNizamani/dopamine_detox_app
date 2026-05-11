import 'package:dartz/dartz.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource dataSource;
  
  AuthRepositoryImpl(this.dataSource);
  
  @override
  Future<Either<String, UserEntity>> signInAnonymously() async {
    try {
      final firebaseUser = await dataSource.signInAnonymously();
      if (firebaseUser != null) {
        return Right(UserModel.fromFirebase(firebaseUser));
      } else {
        return const Left('Sign in failed');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }
  
  @override
  Future<void> signOut() async => await dataSource.signOut();
  
  @override
  Stream<UserEntity?> get authStateChanges {
    return dataSource.userChanges.map((firebaseUser) {
      return firebaseUser != null ? UserModel.fromFirebase(firebaseUser) : null;
    });
  }
}