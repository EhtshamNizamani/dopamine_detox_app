import 'package:dopamine_detox_app/features/activity_log/data/datasources/log_local_datasource.dart';
import 'package:dopamine_detox_app/features/activity_log/data/repositories/log_repository_impl.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/repositories/log_repository.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/usecases/add_log_usecase.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/usecases/get_recent_logs.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/usecases/get_streak.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/usecases/get_today_logs.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/usecases/get_total_logs_count.dart';
import 'package:dopamine_detox_app/features/activity_log/presentation/providers/activity_log_viewmodel.dart';
import 'package:dopamine_detox_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:dopamine_detox_app/features/gamification/data/datasources/gamification_local_ds.dart';
import 'package:dopamine_detox_app/features/gamification/data/repositories/gamification_repository_impl.dart';
import 'package:dopamine_detox_app/features/gamification/domain/repositories/gamification_repository.dart';
import 'package:dopamine_detox_app/features/gamification/domain/usecases/add_xp.dart';
import 'package:dopamine_detox_app/features/gamification/domain/usecases/check_and_update_streak.dart';
import 'package:dopamine_detox_app/features/gamification/domain/usecases/check_daily_open.dart';
import 'package:dopamine_detox_app/features/gamification/domain/usecases/get_gamification.dart';
import 'package:dopamine_detox_app/features/gamification/domain/usecases/unlock_badges.dart';
import 'package:dopamine_detox_app/features/gamification/presentation/providers/gamification_provider.dart';
import 'package:dopamine_detox_app/features/settings/data/datasources/settings_local_ds.dart';
import 'package:dopamine_detox_app/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:dopamine_detox_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:dopamine_detox_app/features/settings/domain/usecases/get_settings.dart';
import 'package:dopamine_detox_app/features/settings/domain/usecases/reset_all_data.dart';
import 'package:dopamine_detox_app/features/settings/domain/usecases/update_notifications.dart';
import 'package:dopamine_detox_app/features/settings/presentation/viewmodels/settings_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_helper.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/check_auth_status.dart';
import '../../features/auth/domain/usecases/sign_in_anonymously.dart';
import '../../features/auth/presentation/viewmodel/auth_viewmodel.dart';
import '../../features/onboarding/presentation/providers/onboarding_provider.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // ========== External ==========
  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPrefs);

  final database = await DatabaseHelper.init();
  sl.registerLazySingleton(() => database);

  // ========== Firebase ==========
  sl.registerLazySingleton(() => FirebaseAuth.instance);

  // ========== Data Sources ==========
  sl.registerLazySingleton(() => AuthLocalDataSource(sl()));
  sl.registerLazySingleton(() => LogLocalDataSource(sl()));
  sl.registerLazySingleton(() => SettingsLocalDataSource(sl()));
  sl.registerLazySingleton(() => GamificationLocalDataSource(sl()));

  // ========== Repositories ==========
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<LogRepository>(() => LogRepositoryImpl(sl()));
  sl.registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton<GamificationRepository>(() => GamificationRepositoryImpl(sl()));

  // ========== Auth Use Cases ==========
  sl.registerLazySingleton(() => SignInAnonymously(sl()));
  sl.registerLazySingleton(() => CheckAuthStatus(sl()));

  // ========== Activity Log Use Cases ==========
  sl.registerLazySingleton(() => AddLogUseCase(sl()));
  sl.registerLazySingleton(() => GetTodayLogsUseCase(sl()));
  sl.registerLazySingleton(() => GetRecentLogsUseCase(sl()));
  sl.registerLazySingleton(() => GetStreakUseCase(sl()));
  sl.registerLazySingleton(() => GetTotalLogsCountUseCase(sl()));

  // ========== Gamification Use Cases ==========
  sl.registerLazySingleton(() => GetGamificationUseCase(sl()));
  sl.registerLazySingleton(() => AddXPUseCase(sl()));
  sl.registerLazySingleton(() => CheckAndUpdateStreakUseCase(sl()));
  sl.registerLazySingleton(() => UnlockBadgesUseCase(sl()));
  sl.registerLazySingleton(() => CheckDailyOpenUseCase(sl()));

  // ========== Settings Use Cases ==========
  sl.registerLazySingleton(() => GetSettings(sl()));
  sl.registerLazySingleton(() => UpdateNotifications(sl()));
  sl.registerLazySingleton(() => ResetAllData(sl()));

  // ========== ViewModels (ALL SINGLETON) ==========
  sl.registerLazySingleton(() => AuthViewModel(
    signInAnonymously: sl(),
    checkAuthStatus: sl(),
  ));

  sl.registerLazySingleton(() => OnboardingViewModel());

  sl.registerLazySingleton(() => ActivityLogViewModel(
    addLogUseCase: sl(),
    getTotalLogsCount: sl(),
    unlockBadges: sl(),
    getTodayLogs: sl(), // NEW

  ));

  sl.registerLazySingleton(() => DashboardViewModel(
    getTodayLogs: sl(),
    getRecentLogs: sl(),
    getStreak: sl(),
    getGamification: sl(),
    checkStreak: sl(),
    unlockBadges: sl(),
    getTotalLogsCount: sl(),
  ));

  sl.registerLazySingleton(() => GamificationViewModel(
    getGamification: sl(),
    addXP: sl(),
    checkDailyOpen: sl(),
  ));

  sl.registerLazySingleton(() => SettingsViewModel(
    getSettings: sl(),
    updateNotifications: sl(),
    resetAllData: sl(),
  ));
}
