import 'package:dopamine_detox_app/core/router/app_router.dart';
import 'package:dopamine_detox_app/features/activity_log/presentation/providers/activity_log_viewmodel.dart';
import 'package:dopamine_detox_app/features/auth/presentation/viewmodel/auth_viewmodel.dart';
import 'package:dopamine_detox_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:dopamine_detox_app/features/gamification/presentation/providers/gamification_provider.dart';
import 'package:dopamine_detox_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:dopamine_detox_app/features/settings/presentation/viewmodels/settings_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initDependencies();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  
  
  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter.router; 
    return MultiProvider(
      providers: [
     ChangeNotifierProvider.value(value: sl<AuthViewModel>()),
      ChangeNotifierProvider.value(value: sl<OnboardingViewModel>()),
      ChangeNotifierProvider.value(value: sl<ActivityLogViewModel>()),
      ChangeNotifierProvider.value(value: sl<DashboardViewModel>()),
      ChangeNotifierProvider.value(value: sl<GamificationViewModel>()),
      ChangeNotifierProvider.value(value: sl<SettingsViewModel>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Dopamine Detox',
        themeMode: ThemeMode.dark,
        darkTheme: AppTheme.darkTheme,
        routerConfig: appRouter,
      ),
    );
  }
}