import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final bool isAnonymous;
  
  const UserEntity({required this.uid, required this.isAnonymous});
  
  @override
  List<Object?> get props => [uid, isAnonymous];
}