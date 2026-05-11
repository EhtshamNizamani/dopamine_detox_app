import '../entities/onboarding.dart';

abstract class OnboardingRepository {
  Future<Onboarding> getOnboarding();
}