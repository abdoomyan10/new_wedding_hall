// features/reports/data/datasources/report_local_data_source.dart
import 'package:wedding_hall/core/error/exceptions.dart';
import 'package:wedding_hall/features/report/data/datasources/report_data_source.dart';

import '../../domain/entities/report_entity.dart';
import '../../domain/entities/report_summary_entity.dart';
import '../models/report_model.dart';
import '../models/report_summary_model.dart';

class ReportLocalDataSourceImpl implements ReportDataSource {
  @override
  Future<List<ReportEntity>> getDailyReports() async {
    try {
      // بيانات وهمية للتطوير - تقارير يومية لآخر 7 أيام
      await Future.delayed(const Duration(milliseconds: 500));

      final now = DateTime.now();
      return List.generate(7, (index) {
        final reportDate = now.subtract(Duration(days: index));
        final totalRevenue = 5000.0 + (index * 1000);
        final expenses = 1000.0 + (index * 200);
        final netProfit = totalRevenue - expenses;
        final profitMargin = totalRevenue > 0 ? (netProfit / totalRevenue) * 100 : 0;

        return ReportModel(
          id: 'daily_${reportDate.toIso8601String()}',
          period: 'يومي',
          date: reportDate,
          totalRevenue: totalRevenue,
          totalPayments: 3000.0 + (index * 800),
          eventsCount: 1 + index,
          expenses: expenses,
          netProfit: netProfit,
          profitMargin: profitMargin.toDouble(),
        );
      });
    } catch (e) {
      throw CacheException('فشل في تحميل التقارير اليومية: ${e.toString()}');
    }
  }

  @override
  Future<List<ReportEntity>> getWeeklyReports() async {
    try {
      // بيانات وهمية للتطوير - تقارير أسبوعية لآخر 4 أسابيع
      await Future.delayed(const Duration(milliseconds: 500));

      final now = DateTime.now();
      return List.generate(4, (index) {
        final reportDate = now.subtract(Duration(days: index * 7));
        final totalRevenue = 35000.0 + (index * 5000);
        final expenses = 7000.0 + (index * 1000);
        final netProfit = totalRevenue - expenses;
        final profitMargin = totalRevenue > 0 ? (netProfit / totalRevenue) * 100 : 0;

        return ReportModel(
          id: 'weekly_${reportDate.toIso8601String()}',
          period: 'أسبوعي',
          date: reportDate,
          totalRevenue: totalRevenue,
          totalPayments: 21000.0 + (index * 3000),
          eventsCount: 7 + index,
          expenses: expenses,
          netProfit: netProfit,
          profitMargin: profitMargin.toDouble(),
        );
      });
    } catch (e) {
      throw CacheException('فشل في تحميل التقارير الأسبوعية: ${e.toString()}');
    }
  }

  @override
  Future<List<ReportEntity>> getMonthlyReports() async {
    try {
      // بيانات وهمية للتطوير - تقارير شهرية لآخر 6 أشهر
      await Future.delayed(const Duration(milliseconds: 500));

      final now = DateTime.now();
      return List.generate(6, (index) {
        final reportDate = DateTime(now.year, now.month - index, 1);
        final totalRevenue = 150000.0 + (index * 20000);
        final expenses = 30000.0 + (index * 5000);
        final netProfit = totalRevenue - expenses;
        final profitMargin = totalRevenue > 0 ? (netProfit / totalRevenue) * 100 : 0;

        return ReportModel(
          id: 'monthly_${reportDate.toIso8601String()}',
          period: 'شهري',
          date: reportDate,
          totalRevenue: totalRevenue,
          totalPayments: 90000.0 + (index * 15000),
          eventsCount: 30 + index,
          expenses: expenses,
          netProfit: netProfit,
          profitMargin: profitMargin.toDouble(),
        );
      });
    } catch (e) {
      throw CacheException('فشل في تحميل التقارير الشهرية: ${e.toString()}');
    }
  }

  @override
  Future<ReportSummaryEntity> getReportSummary(String period) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      // ملخص وهمي حسب الفترة
      double totalRevenue, totalPayments, totalExpenses, netProfit;
      int totalEvents;

      switch (period) {
        case 'daily':
          totalRevenue = 35000.0;
          totalPayments = 21000.0;
          totalExpenses = 7000.0;
          netProfit = totalRevenue - totalExpenses;
          totalEvents = 7;
          break;
        case 'weekly':
          totalRevenue = 140000.0;
          totalPayments = 84000.0;
          totalExpenses = 28000.0;
          netProfit = totalRevenue - totalExpenses;
          totalEvents = 28;
          break;
        case 'monthly':
          totalRevenue = 450000.0;
          totalPayments = 270000.0;
          totalExpenses = 90000.0;
          netProfit = totalRevenue - totalExpenses;
          totalEvents = 90;
          break;
        default:
          totalRevenue = 150000.0;
          totalPayments = 90000.0;
          totalExpenses = 30000.0;
          netProfit = totalRevenue - totalExpenses;
          totalEvents = 30;
      }

      final profitMargin = totalRevenue > 0 ? (netProfit / totalRevenue) * 100 : 0;

      return ReportSummaryModel(
        totalRevenue: totalRevenue,
        totalExpenses: totalExpenses,
        netProfit: netProfit,
        totalPayments: totalPayments,
        totalEvents: totalEvents,
        profitMargin: profitMargin.toDouble(),
      );
    } catch (e) {
      throw CacheException('فشل في تحميل ملخص التقرير: ${e.toString()}');
    }
  }

  @override
  @override
  Future<String> exportReports({
    required List<ReportEntity> reports,
    required String format,
    required String period,
  }) async {
    try {
      // محاكاة عملية التصدير
      await Future.delayed(const Duration(seconds: 2));

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExtension = format == 'pdf' ? 'pdf' : 'xlsx';
      final filePath = '/storage/emulated/0/Download/reports_${period}_$timestamp.$fileExtension';

      // محاكاة نجاح التصدير
      print('✅ تم تصدير ${reports.length} تقرير كـ $format');
      print('📁 المسار: $filePath');

      return filePath;
    } catch (e) {
      throw CacheException('فشل في تصدير التقارير: ${e.toString()}');
    }
  }
  // في ملف report_local_data_source.dart - إضافة الدالة الكاملة
  @override
  Future<List<ReportEntity>> getYearlyReports() async {
    try {
      // بيانات وهمية للتطوير - تقارير سنوية لآخر 5 سنوات
      await Future.delayed(const Duration(milliseconds: 500));

      final now = DateTime.now();
      return List.generate(5, (index) {
        final reportDate = DateTime(now.year - index, 1, 1);
        final totalRevenue = 1800000.0 + (index * 200000);
        final expenses = 360000.0 + (index * 40000);
        final netProfit = totalRevenue - expenses;
        final profitMargin = totalRevenue > 0 ? (netProfit / totalRevenue) * 100 : 0;

        return ReportModel(
          id: 'yearly_${reportDate.toIso8601String()}',
          period: 'سنوي',
          date: reportDate,
          totalRevenue: totalRevenue,
          totalPayments: 1080000.0 + (index * 120000),
          eventsCount: 365 + index,
          expenses: expenses,
          netProfit: netProfit,
          profitMargin: profitMargin.toDouble(),
        );
      });
    } catch (e) {
      throw CacheException('فشل في تحميل التقارير السنوية: ${e.toString()}');
    }
  }
}