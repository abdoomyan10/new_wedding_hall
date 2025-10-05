// features/reports/domain/usecases/get_daily_reports_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:new_wedding_hall/core/error/failure.dart';
import 'package:new_wedding_hall/core/usecase/usecase.dart';

import '../entities/report_entity.dart';
import '../repositories/report_repository.dart';

class GetDailyReportsUseCase implements UseCase<List<ReportEntity>, NoParams> {
  final ReportRepository repository;

  GetDailyReportsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ReportEntity>>> call(NoParams params) async {
    return await repository.getDailyReports();
  }
}
