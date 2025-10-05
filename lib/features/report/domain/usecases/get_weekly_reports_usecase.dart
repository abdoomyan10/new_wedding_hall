// get_weekly_reports_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:wedding_hall/core/error/failure.dart';
import 'package:wedding_hall/core/usecase/usecase.dart';

import '../entities/report_entity.dart';
import '../repositories/report_repository.dart';

class GetWeeklyReportsUseCase implements UseCase<List<ReportEntity>, DateTime> {
  final ReportRepository repository;

  GetWeeklyReportsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ReportEntity>>> call(DateTime date) async {
    return await repository.getWeeklyReports();
  }
}