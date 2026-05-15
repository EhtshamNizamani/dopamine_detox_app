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
import 'package:dopamine_detox_app/features/gamification/domain/usecases/get_gamification.dart';
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
import 'package:sqflite/sqflite.dart';

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
  sl.registerLazySingleton<SharedPreferences>(() => sharedPrefs);
  
  final database = await DatabaseHelper.init();
  sl.registerLazySingleton<Database>(() => database);
  
  // ========== Firebase ==========
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  
  // ========== Auth Feature ==========
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSource(sl<FirebaseAuth>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthLocalDataSource>()),
  );
    sl.registerLazySingleton<LogLocalDataSource>(() => LogLocalDataSource(sl<Database>()));
  sl.registerLazySingleton<LogRepository>(() => LogRepositoryImpl(sl<LogLocalDataSource>()));
  sl.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSource(sl<SharedPreferences>()),
  );
    sl.registerLazySingleton<GamificationLocalDataSource>(
    () => GamificationLocalDataSource(sl<SharedPreferences>()),
  );

  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(sl<SettingsLocalDataSource>(), sl<Database>()),
  );

  // Gamification
  sl.registerLazySingleton<GamificationRepository>(
    () => GamificationRepositoryImpl(sl<GamificationLocalDataSource>()),
  );
  sl.registerLazySingleton<GetGamificationUseCase>(
    () => GetGamificationUseCase(sl<GamificationRepository>()),
  );
  sl.registerLazySingleton<AddXPUseCase>(
    () => AddXPUseCase(sl<GamificationRepository>()),
  );
  sl.registerFactory<GamificationViewModel>(
    () => GamificationViewModel(
      getGamification: sl<GetGamificationUseCase>(),
      addXP: sl<AddXPUseCase>(),
    ),
  );



  // Use Cases
  sl.registerLazySingleton<SignInAnonymously>(
    () => SignInAnonymously(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<CheckAuthStatus>(
    () => CheckAuthStatus(sl<AuthRepository>()),
  );
    sl.registerLazySingleton<AddLogUseCase>(() => AddLogUseCase(sl<LogRepository>()));
  sl.registerLazySingleton<GetTodayLogsUseCase>(() => GetTodayLogsUseCase(sl<LogRepository>()));
  sl.registerLazySingleton<GetRecentLogsUseCase>(() => GetRecentLogsUseCase(sl<LogRepository>()));
  sl.registerLazySingleton<GetStreakUseCase>(() => GetStreakUseCase(sl<LogRepository>()));
  sl.registerLazySingleton<GetSettings>(() => GetSettings(sl<SettingsRepository>()));
  sl.registerLazySingleton<UpdateNotifications>(() => UpdateNotifications(sl<SettingsRepository>()));
  sl.registerLazySingleton<ResetAllData>(() => ResetAllData(sl<SettingsRepository>()));
sl.registerLazySingleton<GetTotalLogsCountUseCase>(
  () => GetTotalLogsCountUseCase(sl<LogRepository>()),
);

  
  // ViewModels
  sl.registerFactory<AuthViewModel>(
    () => AuthViewModel(
      signInAnonymously: sl<SignInAnonymously>(),
      checkAuthStatus: sl<CheckAuthStatus>(),
    ),
  );
  sl.registerFactory<OnboardingViewModel>(
    () => OnboardingViewModel(sl<SharedPreferences>()),
  );
    sl.registerFactory<ActivityLogViewModel>(() => ActivityLogViewModel(addLogUseCase: sl<AddLogUseCase>(), addXPUseCase: sl<AddXPUseCase>(), getTotalLogsCount: sl<GetTotalLogsCountUseCase>()  ));
  sl.registerFactory<DashboardViewModel>(() => DashboardViewModel(
    getTodayLogs: sl<GetTodayLogsUseCase>(),
    getRecentLogs: sl<GetRecentLogsUseCase>(),
    getStreak: sl<GetStreakUseCase>(),
  ));

    sl.registerFactory<SettingsViewModel>(
    () => SettingsViewModel(
      getSettings: sl<GetSettings>(),
      updateNotifications: sl<UpdateNotifications>(),
      resetAllData: sl<ResetAllData>(),
    ),
  );


}