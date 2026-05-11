import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_constants.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> init() async {
    if (_database != null) return _database!;
    
    String path = join(await getDatabasesPath(), AppConstants.dbName);
    _database = await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE activity_logs(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            activityName TEXT NOT NULL,
            intensity INTEGER NOT NULL,
            timestamp INTEGER NOT NULL
          )
        ''');
      },
    );
    return _database!;
  }
}