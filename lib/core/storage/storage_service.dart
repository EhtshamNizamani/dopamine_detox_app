// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class StorageService {
//   static final StorageService _instance = StorageService._internal();
//   factory StorageService() => _instance;
//   StorageService._internal();

//   late SharedPreferences _prefs;
//   final FlutterSecureStorage _secure = const FlutterSecureStorage();

//   Future<void> init() async {
//     _prefs = await SharedPreferences.getInstance();
//   }

//   // ── Shared Preferences ──────────────────────────────
//   Future<void> setString(String key, String value) async =>
//       _prefs.setString(key, value);
//   String? getString(String key) => _prefs.getString(key);

//   Future<void> setBool(String key, bool value) async =>
//       _prefs.setBool(key, value);
//   bool? getBool(String key) => _prefs.getBool(key);

//   Future<void> remove(String key) async => _prefs.remove(key);
//   Future<void> clearAll() async => _prefs.clear();

//   // ── Secure Storage ───────────────────────────────────
//   Future<void> setSecure(String key, String value) async =>
//       _secure.write(key: key, value: value);
//   Future<String?> getSecure(String key) async => _secure.read(key: key);
//   Future<void> removeSecure(String key) async => _secure.delete(key: key);
//   Future<void> clearSecure() async => _secure.deleteAll();
// }
