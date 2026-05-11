import 'package:dopamine_detox_app/core/constants/app_constants.dart';
import 'package:dopamine_detox_app/features/activity_log/presentation/screen/activity_log_screen.dart';
import 'package:dopamine_detox_app/features/dashboard/presentation/screen/dashboard_screen.dart';
import 'package:dopamine_detox_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:dopamine_detox_app/features/settings/presentation/pages/settings_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRouter {
  AppRouter._();

static final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    // Check onboarding status
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool(AppConstants.keyOnboardingCompleted) ?? false;
    
    if (!onboardingCompleted && state.matchedLocation != '/onboarding') {
      return '/onboarding';
    }
    if (onboardingCompleted && state.matchedLocation == '/') {
      return '/dashboard';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/activity-log',
      name: 'activity-log',
      builder: (context, state) => const ActivityLogScreen(),
    ),
    GoRoute(path:   '/settings', name: 'settings', builder: (context, state) => const SettingsScreen()),
  ],
);

}
