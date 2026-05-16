class AppConstants {
  AppConstants._();

  static const String appName = 'Dopamine Detox';
  static const String appVersion = '1.0.0';

  // SharedPreferences keys
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyNotificationEnabled = 'notification_enabled';

  // Database
  static const String dbName = 'dopamine_detox.db';
  static const int dbVersion = 1;

  // Dopamine score config
  static const int maxDopamineScore = 100;
  static const int minDopamineScore = 0;
  static const int streakThreshold = 80;

  // Penalty per intensity
  static const int lowIntensityPenalty = 3;
  static const int mediumIntensityPenalty = 7;
  static const int highIntensityPenalty = 15;

  // XP Rewards — ONLY for positive behavior, NEVER for logging triggers
  static const int xpGoodDay = 20;      // Score >= 80
  static const int xpPerfectDay = 50;   // Score == 100
  static const int xpStreakMaintain = 10; // Streak continues
  static const int xpDailyOpen = 2;     // Daily app open

  // Level thresholds
  static const Map<int, int> levelThresholds = {
    1: 0,
    2: 100,
    3: 250,
    4: 400,
    5: 500,
    6: 600,
    7: 700,
    8: 800,
    9: 900,
    10: 1000,
  };

  // Badge definitions
  static const String badgeFirstLog = 'first_log';
  static const String badgeStreak3 = 'streak_3';
  static const String badgeStreak7 = 'streak_7';
  static const String badgeStreak10 = 'streak_10';
  static const String badgeLevel5 = 'level_5';
  static const String badgeLevel10 = 'level_10';
  static const String badgePerfectDay = 'perfect_day';

  static const Map<String, String> badgeNames = {
    badgeFirstLog: '🏅 First Log',
    badgeStreak3: '🔥 3-Day Streak',
    badgeStreak7: '🔥 7-Day Streak',
    badgeStreak10: '🏆 10-Day Streak',
    badgeLevel5: '⭐ Level 5',
    badgeLevel10: '⭐ Level 10',
    badgePerfectDay: '🧘 Perfect Day',
  };
}