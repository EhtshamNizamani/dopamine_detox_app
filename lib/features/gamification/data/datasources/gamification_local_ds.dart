import 'package:shared_preferences/shared_preferences.dart';

class GamificationLocalDataSource {
  final SharedPreferences prefs;
  static const String keyTotalXP = 'total_xp';
  static const String keyBadges = 'unlocked_badges';

  GamificationLocalDataSource(this.prefs);

  int getTotalXP() => prefs.getInt(keyTotalXP) ?? 0;

  Future<void> setTotalXP(int xp) async => await prefs.setInt(keyTotalXP, xp);

  List<String> getBadges() {
    final badgeString = prefs.getString(keyBadges);
    if (badgeString == null) return [];
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
  }
}