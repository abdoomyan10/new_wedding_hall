// features/reports/presentation/cubit/report_cubit.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_wedding_hall/core/error/failure.dart';
import 'package:new_wedding_hall/core/usecase/usecase.dart';

import '../../domain/entities/report_entity.dart';
import '../../domain/entities/report_summary_entity.dart';
import '../../domain/usecases/export_reports_usecase.dart';
import '../../domain/usecases/get_daily_reports_usecase.dart';
import '../../domain/usecases/get_monthly_reports_usecase.dart';
import '../../domain/usecases/get_report_summary_usecase.dart';
import '../../domain/usecases/get_weekly_reports_usecase.dart';
import '../../domain/usecases/get_yearly_reports_usecase.dart';
import 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  final GetDailyReportsUseCase getDailyReportsUseCase;
  final GetWeeklyReportsUseCase getWeeklyReportsUseCase;
  final GetMonthlyReportsUseCase getMonthlyReportsUseCase;
  final GetYearlyReportsUseCase getYearlyReportsUseCase;
  final GetReportSummaryUseCase getReportSummaryUseCase;
  final ExportReportsUseCase exportReportsUseCase;

  ReportCubit({
    required this.getDailyReportsUseCase,
    required this.getWeeklyReportsUseCase,
    required this.getMonthlyReportsUseCase,
    required this.getYearlyReportsUseCase,
    required this.getReportSummaryUseCase,
    required this.exportReportsUseCase,
  }) : super(const ReportInitial());

  // تحميل التقارير اليومية
  Future<void> loadDailyReports() async {
    emit(const ReportLoading());

    final result = await getDailyReportsUseCase(NoParams() as NoParams);

    result.fold(
      (failure) {
        emit(ReportError(_mapFailureToMessage(failure)));
      },
      (reports) async {
        final summaryResult = await getReportSummaryUseCase('daily');

        summaryResult.fold(
          (summaryFailure) {
            emit(ReportError(_mapFailureToMessage(summaryFailure)));
          },
          (summary) {
            emit(
              ReportLoaded(
                reports: reports,
                summary: summary,
                selectedPeriod: 'daily',
              ),
            );
          },
        );
      },
    );
  }

  // تحميل التقارير الأسبوعية
  Future<void> loadWeeklyReports() async {
    emit(const ReportLoading());

    final result = await getWeeklyReportsUseCase(DateTime(2023, 10, 1));

    result.fold(
      (failure) {
        emit(ReportError(_mapFailureToMessage(failure)));
      },
      (reports) async {
        final summaryResult = await getReportSummaryUseCase('weekly');

        summaryResult.fold(
          (summaryFailure) {
            emit(ReportError(_mapFailureToMessage(summaryFailure)));
          },
          (summary) {
            emit(
              ReportLoaded(
                reports: reports,
                summary: summary,
                selectedPeriod: 'weekly',
              ),
            );
          },
        );
      },
    );
  }

  // تحميل التقارير الشهرية
  Future<void> loadMonthlyReports() async {
    emit(const ReportLoading());

    final result = await getMonthlyReportsUseCase(DateTime(2023, 10, 1));

    result.fold(
      (failure) {
        emit(ReportError(_mapFailureToMessage(failure)));
      },
      (reports) async {
        final summaryResult = await getReportSummaryUseCase('monthly');

        summaryResult.fold(
          (summaryFailure) {
            emit(ReportError(_mapFailureToMessage(summaryFailure)));
          },
          (summary) {
            emit(
              ReportLoaded(
                reports: reports,
                summary: summary,
                selectedPeriod: 'monthly',
              ),
            );
          },
        );
      },
    );
  }

  // تحميل التقارير السنوية
  Future<void> loadYearlyReports() async {
    emit(const ReportLoading());

    final result = await getYearlyReportsUseCase(DateTime(2023, 10, 1));

    result.fold(
      (failure) {
        emit(ReportError(_mapFailureToMessage(failure)));
      },
      (reports) async {
        final summaryResult = await getReportSummaryUseCase('yearly');

        summaryResult.fold(
          (summaryFailure) {
            emit(ReportError(_mapFailureToMessage(summaryFailure)));
          },
          (summary) {
            emit(
              ReportLoaded(
                reports: reports,
                summary: summary,
                selectedPeriod: 'yearly',
              ),
            );
          },
        );
      },
    );
  }

  // تحميل الملخص فقط
  Future<void> loadReportSummary(String period) async {
    final result = await getReportSummaryUseCase(period);

    result.fold(
      (failure) {
        _showExportError(
          'فشل في تحميل الملخص: ${_mapFailureToMessage(failure)}',
        );
      },
      (summary) {
        if (state is ReportLoaded) {
          final currentState = state as ReportLoaded;
          emit(
            ReportLoaded(
              reports: currentState.reports,
              summary: summary,
              selectedPeriod: currentState.selectedPeriod,
            ),
          );
        }
      },
    );
  }

  // تصدير التقارير كـ PDF
  Future<void> exportToPdf() async {
    if (state is! ReportLoaded) {
      _showExportError('لا توجد تقارير لتصديرها');
      return;
    }

    final currentState = state as ReportLoaded;

    if (currentState.reports.isEmpty) {
      _showExportError('لا توجد تقارير لتصديرها');
      return;
    }

    try {
      final result = await exportReportsUseCase(
        ExportReportsParams(
          reports: currentState.reports,
          format: ExportFormat.pdf,
          period: currentState.selectedPeriod,
        ),
      );

      result.fold(
        (failure) {
          _showExportError(_mapFailureToMessage(failure));
        },
        (filePath) {
          _showExportSuccess('تم التصدير بنجاح كـ PDF: $filePath');
        },
      );
    } catch (e) {
      _showExportError('حدث خطأ أثناء التصدير: $e');
    }
  }

  // تصدير التقارير كـ Excel
  Future<void> exportToExcel() async {
    if (state is! ReportLoaded) {
      _showExportError('لا توجد تقارير لتصديرها');
      return;
    }

    final currentState = state as ReportLoaded;

    if (currentState.reports.isEmpty) {
      _showExportError('لا توجد تقارير لتصديرها');
      return;
    }

    try {
      final result = await exportReportsUseCase(
        ExportReportsParams(
          reports: currentState.reports,
          format: ExportFormat.excel,
          period: currentState.selectedPeriod,
        ),
      );

      result.fold(
        (failure) {
          _showExportError(_mapFailureToMessage(failure));
        },
        (filePath) {
          _showExportSuccess('تم التصدير بنجاح كـ Excel: $filePath');
        },
      );
    } catch (e) {
      _showExportError('حدث خطأ أثناء التصدير: $e');
    }
  }

  // تصدير التقارير مع تحديد التنسيق
  Future<void> exportReports(ExportFormat format) async {
    if (state is! ReportLoaded) {
      _showExportError('لا توجد تقارير لتصديرها');
      return;
    }

    final currentState = state as ReportLoaded;

    if (currentState.reports.isEmpty) {
      _showExportError('لا توجد تقارير لتصديرها');
      return;
    }

    try {
      final result = await exportReportsUseCase(
        ExportReportsParams(
          reports: currentState.reports,
          format: format,
          period: currentState.selectedPeriod,
        ),
      );

      result.fold(
        (failure) {
          _showExportError(_mapFailureToMessage(failure));
        },
        (filePath) {
          final formatName = format == ExportFormat.pdf ? 'PDF' : 'Excel';
          _showExportSuccess('تم التصدير بنجاح كـ $formatName: $filePath');
        },
      );
    } catch (e) {
      _showExportError('حدث خطأ أثناء التصدير: $e');
    }
  }

  // تحديث تقرير محدد
  void updateReport(ReportEntity updatedReport) {
    if (state is! ReportLoaded) return;

    final currentState = state as ReportLoaded;
    final updatedReports = currentState.reports.map((report) {
      return report.id == updatedReport.id ? updatedReport : report;
    }).toList();

    final newSummary = _calculateSummary(updatedReports);

    emit(
      ReportLoaded(
        reports: updatedReports,
        summary: newSummary,
        selectedPeriod: currentState.selectedPeriod,
      ),
    );
  }

  // إضافة تقرير جديد
  void addReport(ReportEntity newReport) {
    if (state is! ReportLoaded) return;

    final currentState = state as ReportLoaded;
    final updatedReports = [...currentState.reports, newReport];
    final newSummary = _calculateSummary(updatedReports);

    emit(
      ReportLoaded(
        reports: updatedReports,
        summary: newSummary,
        selectedPeriod: currentState.selectedPeriod,
      ),
    );
  }

  // حذف تقرير
  void deleteReport(String reportId) {
    if (state is! ReportLoaded) return;

    final currentState = state as ReportLoaded;
    final updatedReports = currentState.reports
        .where((report) => report.id != reportId)
        .toList();
    final newSummary = _calculateSummary(updatedReports);

    emit(
      ReportLoaded(
        reports: updatedReports,
        summary: newSummary,
        selectedPeriod: currentState.selectedPeriod,
      ),
    );
  }

  // حساب الملخص الإجمالي من التقارير
  ReportSummaryEntity _calculateSummary(List<ReportEntity> reports) {
    if (reports.isEmpty) {
      return const ReportSummaryEntity(
        totalRevenue: 0,
        totalExpenses: 0,
        netProfit: 0,
        totalPayments: 0,
        totalEvents: 0,
        profitMargin: 0,
      );
    }

    double totalRevenue = 0;
    double totalExpenses = 0;
    double totalNetProfit = 0;
    double totalPayments = 0;
    int totalEvents = 0;

    for (final report in reports) {
      totalRevenue += report.totalRevenue;
      totalExpenses += report.expenses;
      totalNetProfit += report.netProfit;
      totalPayments += report.totalPayments;
      totalEvents += report.eventsCount;
    }

    double profitMargin = totalRevenue > 0
        ? (totalNetProfit / totalRevenue) * 100
        : 0;

    return ReportSummaryEntity(
      totalRevenue: totalRevenue,
      totalExpenses: totalExpenses,
      netProfit: totalNetProfit,
      totalPayments: totalPayments,
      totalEvents: totalEvents,
      profitMargin: profitMargin,
    );
  }

  // تحويل Failure إلى رسالة خطأ
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'خطأ في الاتصال بالخادم';
      case NetworkFailure:
        return 'خطأ في الاتصال بالإنترنت';
      case CacheFailure:
        return 'خطأ في التخزين المحلي';
      default:
        return 'حدث خطأ غير متوقع';
    }
  }

  // عرض رسائل الخطأ (يمكن استبدالها بـ SnackBar في الواجهة)
  void _showExportError(String message) {
    // في التطبيق الحقيقي، يمكن استخدام BlocListener لعرض SnackBar
    print('❌ خطأ في التصدير: $message');
    // أو يمكن إضافة حالة جديدة لعرض الأخطاء
  }

  void _showExportSuccess(String message) {
    // في التطبيق الحقيقي، يمكن استخدام BlocListener لعرض SnackBar
    print('✅ نجاح: $message');
    // أو يمكن إضافة حالة جديدة لعرض النجاح
  }

  // الحصول على التقارير الحالية
  List<ReportEntity> get currentReports {
    if (state is ReportLoaded) {
      return (state as ReportLoaded).reports;
    }
    return [];
  }

  // الحصول على الملخص الحالي
  ReportSummaryEntity? get currentSummary {
    if (state is ReportLoaded) {
      return (state as ReportLoaded).summary;
    }
    return null;
  }

  // الحصول على الفترة المحددة حالياً
  String get currentPeriod {
    if (state is ReportLoaded) {
      return (state as ReportLoaded).selectedPeriod;
    }
    return 'daily';
  }

  // تنظيف الموارد عند إغلاق Cubit
  @override
  Future<void> close() {
    // تنظيف أي موارد مطلوبة
    return super.close();
  }
}
