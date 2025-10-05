

import '../../domain/entities/report_entity.dart';
import '../../domain/entities/report_summary_entity.dart';

abstract class ReportState {
  const ReportState();
}

class ReportInitial extends ReportState {
  const ReportInitial();
}

class ReportLoading extends ReportState {
  const ReportLoading();
}

class ReportLoaded extends ReportState {
  final List<ReportEntity> reports;
  final ReportSummaryEntity? summary;
  final String selectedPeriod;

  const ReportLoaded({
    required this.reports,
    this.summary,
    this.selectedPeriod = 'daily',
  });

  ReportLoaded copyWith({
    List<ReportEntity>? reports,
    ReportSummaryEntity? summary,
    String? selectedPeriod,
  }) {
    return ReportLoaded(
      reports: reports ?? this.reports,
      summary: summary ?? this.summary,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
    );
  }
}

class ReportError extends ReportState {
  final String message;

  const ReportError(this.message);
}