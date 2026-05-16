import 'package:shared_preferences/shared_preferences.dart';

class GamificationLocalDataSource {
  final SharedPreferences prefs;
  
  static const String keyTotalXP = 'total_xp';
  static const String keyBadges = 'unlocked_badges';
  static const String keyCurrentStreak = 'current_streak';
  static const String keyLastStreakCheck = 'last_streak_check';
  static const String keyLastDailyOpen = 'last_daily_open';

  GamificationLocalDataSource(this.prefs);

  int getTotalXP() => prefs.getInt(keyTotalXP) ?? 0;

  Future<void> setTotalXP(int xp) async => await prefs.setInt(keyTotalXP, xp);

  int getCurrentStreak() => prefs.getInt(keyCurrentStreak) ?? 0;

  Future<void> setCurrentStreak(int streak) async => await prefs.setInt(keyCurrentStreak, streak);

  DateTime? getLastStreakCheckDate() {
    final millis = prefs.getInt(keyLastStreakCheck);
    return millis != null ? DateTime.fromMillisecondsSinceEpoch(millis) : null;
  }

  Future<void> setLastStreakCheckDate(DateTime date) async {
    await prefs.setInt(keyLastStreakCheck, date.millisecondsSinceEpoch);
  }

  DateTime? getLastDailyOpenDate() {
    final millis = prefs.getInt(keyLastDailyOpen);
    return millis != null ? DateTime.fromMillisecondsSinceEpoch(millis) : null;
  }

  Future<void> setLastDailyOpenDate(DateTime date) async {
    await prefs.setInt(keyLastDailyOpen, date.millisecondsSinceEpoch);
  }

  List<String> getBadges() {
    final badgeString = prefs.getString(keyBadges);
    if (badgeString == null || badgeString.isEmpty) return [];
    return badgeString.split(',');
  }

  Future<void> addBadge(String badgeId) async {
    final current = getBadges();
    if (current.contains(badgeId)) return;
    current.add(badgeId);
    await prefs.setString(keyBadges, current.join(','));
  }

  Future<void> resetGamification() async {
    await prefs.remove(keyTotalXP);
    await prefs.remove(keyBadges);
    await prefs.remove(keyCurrentStreak);
    await prefs.remove(keyLastStreakCheck);
    await prefs.remove(keyLastDailyOpen);
  }
}