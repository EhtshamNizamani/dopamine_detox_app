import 'package:dopamine_detox_app/features/dashboard/domain/entities/dashboard.dart';

import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_ds.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  DashboardRepositoryImpl(this.remoteDataSource);

  @override
  Future<Dashboard> getDashboard() {
    // TODO: implement getDashboard
    throw UnimplementedError();
  }
}