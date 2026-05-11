import 'package:equatable/equatable.dart';

class Dashboard extends Equatable {
  final String id;
  const Dashboard({required this.id});

  @override
  List<Object?> get props => [id];
}