// features/reports/presentation/pages/reports_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/dependencies.dart';
import '../cubit/report_cubit.dart';
import '../cubit/report_state.dart';
import '../widgets/export_reports_dialog.dart';
import '../widgets/time_period_selector.dart';
import '../widgets/report_summary_card.dart';
import '../widgets/reports_list.dart';
import 'saved_reports_page.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchBar = false;

  @override
  void initState() {
    super.initState();
    // تحميل التقارير اليومية افتراضياً
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportCubit>().loadDailyReports();
    });
  }

  void _toggleSearchBar() {
    setState(() {
      _showSearchBar = !_showSearchBar;
      if (!_showSearchBar) {
        _searchController.clear();
        // إعادة تحميل جميع التقارير عند إغلاق البحث
        _loadReportsBasedOnCurrentPeriod();
      }
    });
  }

  void _loadReportsBasedOnCurrentPeriod() {
    final cubit = context.read<ReportCubit>();
    final state = cubit.state;

    if (state is ReportLoaded) {
      switch (state.selectedPeriod) {
        case 'daily':
          cubit.loadDailyReports();
          break;
        case 'weekly':
          cubit.loadWeeklyReports();
          break;
        case 'monthly':
          cubit.loadMonthlyReports();
          break;
        case 'yearly':
          cubit.loadYearlyReports();
          break;
      }
    } else {
      cubit.loadDailyReports();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: _showSearchBar
            ? TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'ابحث في التقارير...',
            hintStyle: const TextStyle(color: AppColors.gray500),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.close),
              onPressed: _toggleSearchBar,
            ),
          ),
          style: const TextStyle(color: AppColors.black),
          onChanged: (value) {
            // TODO: تطبيق البحث في التقارير
          },
        )
            : const Text(
          'التقارير والإحصائيات',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.paleGold,
          ),
        ),
        backgroundColor: AppColors.deepRed,
        elevation: 4,
        actions: [
          if (!_showSearchBar)
            IconButton(
              icon: const Icon(Icons.search, color: AppColors.paleGold),
              onPressed: _toggleSearchBar,
            ),
          // زر التقارير المحفوظة
          IconButton(
            icon: const Icon(Icons.folder, color: AppColors.paleGold),
            tooltip: 'التقارير المحفوظة',
            onPressed: () => _navigateToSavedReports(context),
          ),
          // زر تصدير PDF
          PopupMenuButton<String>(
            icon: const Icon(Icons.picture_as_pdf, color: AppColors.paleGold),
            tooltip: 'تصدير PDF',
            onSelected: (value) {
              switch (value) {
                case 'save_report':
                  _savePdfReport(context);
                  break;
                case 'print_report':
                  _printPdfReport(context);
                  break;
                case 'saved_reports':
                  _navigateToSavedReports(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'save_report',
                child: Row(
                  children: [
                    Icon(Icons.save, color: Colors.green),
                    SizedBox(width: 8),
                    Text('حفظ PDF على الجهاز'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'print_report',
                child: Row(
                  children: [
                    Icon(Icons.print, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('طباعة مباشرة'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'saved_reports',
                child: Row(
                  children: [
                    Icon(Icons.folder_open, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('التقارير المحفوظة'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.paleGold),
            tooltip: 'تحديث البيانات',
            onPressed: () => _loadReportsBasedOnCurrentPeriod(),
          ),
        ],
      ),
      body: BlocProvider<ReportCubit>(
        create: (context) => getIt<ReportCubit>(),
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // قسم الإحصائيات
              const SliverToBoxAdapter(child: ReportSummaryCard()),

              // فلترة الفترة الزمنية
              const SliverToBoxAdapter(child: TimePeriodSelector()),

              // عنوان قائمة التقارير
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  color: AppColors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'قائمة التقارير',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.deepRed,
                        ),
                      ),
                      BlocBuilder<ReportCubit, ReportState>(
                        builder: (context, state) {
                          if (state is ReportLoaded) {
                            return Text(
                              '${state.reports.length} تقرير',
                              style: const TextStyle(
                                color: AppColors.gray500,
                                fontSize: 14,
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: const ReportsList(),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      // زر التحميل لأعلى
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => ExportReportsDialog.show(context),
      backgroundColor: AppColors.deepRed,
      foregroundColor: AppColors.paleGold,
      child: const Icon(Icons.download),
    );
  }

  Widget _buildBottomAppBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.gray500.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // زر التصدير
              OutlinedButton.icon(
                onPressed: () => ExportReportsDialog.show(context),
                icon: const Icon(Icons.download, size: 18),
                label: const Text('تصدير'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.gold,
                  side: const BorderSide(color: AppColors.deepRed),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              // زر التحميل لأعلى
              IconButton(
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.deepRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_upward,
                    color: AppColors.gold,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _savePdfReport(BuildContext context) async {
    try {
      final cubit = context.read<ReportCubit>();
      await cubit.generateAndSavePdfReport();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ تقرير PDF بنجاح'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في حفظ التقرير: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _printPdfReport(BuildContext context) async {
    try {
      final cubit = context.read<ReportCubit>();
      await cubit.generatePdfReport();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إعداد التقرير للطباعة بنجاح'),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في طباعة التقرير: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _navigateToSavedReports(BuildContext context) {
    final reportCubit = context.read<ReportCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: reportCubit,
          child: const SavedReportsPage(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}