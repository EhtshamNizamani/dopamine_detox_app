import 'package:equatable/equatable.dart';

class Onboarding extends Equatable {
  final String id;
  const Onboarding({required this.id});

  @override
  List<Object?> get props => [id];
}