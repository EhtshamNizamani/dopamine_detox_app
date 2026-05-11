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
}
