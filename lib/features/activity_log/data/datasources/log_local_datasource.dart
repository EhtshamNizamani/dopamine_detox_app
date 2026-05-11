import 'package:sqflite/sqflite.dart';
import '../models/log_entry_model.dart';

class LogLocalDataSource {
  final Database db;

  LogLocalDataSource(this.db);

  Future<void> insertLog(LogEntryModel log) async {
    await db.insert('activity_logs', log.toMap());
  }

  Future<List<LogEntryModel>> getLogsForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final List<Map<String, dynamic>> maps = await db.query(
      'activity_logs',
      where: 'timestamp >= ? AND timestamp < ?',
      whereArgs: [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) => LogEntryModel.fromMap(map)).toList();
  }

  Future<List<LogEntryModel>> getRecentLogs({int limit = 10}) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'activity_logs',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return maps.map((map) => LogEntryModel.fromMap(map)).toList();
  }
}