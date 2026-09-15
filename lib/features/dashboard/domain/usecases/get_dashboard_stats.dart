import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../base/errors/base/app_exception.dart';
import '../../../../base/errors/uncaught/app_uncaught_exception.dart';
import '../entities/dashboard_stats.dart';
import '../repositories/dashboard_repository.dart';

@injectable
class GetDashboardStats {
  final DashboardRepository _repository;

  GetDashboardStats(this._repository);

  Future<Either<AppException, DashboardStats>> execute() async {
    try {
      final result = await _repository.getStats();
      return Right(result);
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }
}
