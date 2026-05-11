import '../../domain/entities/log_entry_entity.dart';

class LogEntryModel extends LogEntryEntity {
  const LogEntryModel({
    super.id,
    required super.activityName,
    required super.intensity,
    required super.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activityName': activityName,
      'intensity': intensity,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory LogEntryModel.fromMap(Map<String, dynamic> map) {
    return LogEntryModel(
      id: map['id'],
      activityName: map['activityName'],
      intensity: map['intensity'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }
}