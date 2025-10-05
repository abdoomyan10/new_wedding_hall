// get_report_summary_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:new_wedding_hall/core/error/failure.dart';
import 'package:new_wedding_hall/core/usecase/usecase.dart';

import '../entities/report_summary_entity.dart';
import '../repositories/report_repository.dart';

class GetReportSummaryUseCase implements UseCase<ReportSummaryEntity, String> {
  final ReportRepository repository;

  GetReportSummaryUseCase(this.repository);

  @override
  Future<Either<Failure, ReportSummaryEntity>> call(String period) async {
    return await repository.getReportSummary(period);
  }
}
