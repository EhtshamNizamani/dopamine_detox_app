import 'package:dopamine_detox_app/features/onboarding/domain/entities/onboarding.dart';

import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_remote_ds.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingRemoteDataSource remoteDataSource;
  OnboardingRepositoryImpl(this.remoteDataSource);

  @override
  Future<Onboarding> getOnboarding() {
    // TODO: implement getOnboarding
    throw UnimplementedError();
  }
}