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
  
  // Register auth dependencies (simplified - add to injection.dart later)
  // For now, create manually in main.
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  
  // TODO: create AuthViewModel using sl.get() after registering in initDependencies
  // For brevity, I'll show structure:
  
  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter.router; // Assume this is defined in router.dart
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<AuthViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<OnboardingViewModel>()),
        ChangeNotifierProvider(create:  (_) => sl<DashboardViewModel>()),
        ChangeNotifierProvider(create:  (_) => sl<ActivityLogViewModel>()),
        ChangeNotifierProvider(create:  (_) => sl<SettingsViewModel>()),
        ChangeNotifierProvider(create:  (_) => sl<GamificationViewModel>()),
      ],
      child: MaterialApp.router(
        title: 'Dopamine Detox',
        themeMode: ThemeMode.dark,
        darkTheme: AppTheme.darkTheme,
        routerConfig: appRouter,
      ),
    );
  }
}