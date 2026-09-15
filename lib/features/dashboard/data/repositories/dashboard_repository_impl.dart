import 'package:injectable/injectable.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_local_datasource.dart';

@LazySingleton(as: DashboardRepository)
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardLocalDataSource _localDataSource;

  DashboardRepositoryImpl(this._localDataSource);

  @override
  Future<DashboardStats> getStats() {
    return _localDataSource.getStats();
  }
}
