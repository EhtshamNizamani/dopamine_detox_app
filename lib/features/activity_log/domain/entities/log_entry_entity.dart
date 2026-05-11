import 'package:equatable/equatable.dart';

class LogEntryEntity extends Equatable {
  final int? id;
  final String activityName;
  final int intensity; // 1=Low, 2=Medium, 3=High
  final DateTime timestamp;

  const LogEntryEntity({
    this.id,
    required this.activityName,
    required this.intensity,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, activityName, intensity, timestamp];
}