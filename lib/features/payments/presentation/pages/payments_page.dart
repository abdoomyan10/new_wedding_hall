// features/payments/presentation/pages/payments_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../cubit/payment_cubit.dart';
import '../widgets/add_payment_dialog.dart';
import '../widgets/payment_filter_dialog.dart';
import '../widgets/payment_filters.dart';
import '../widgets/payment_stats_section.dart';
import '../widgets/payments_list.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<PaymentCubit>().loadPayments();
  }

  void _showAddPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddPaymentDialog(),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => const PaymentFilterDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // App Bar مع البحث
            SliverAppBar(
              title: _showSearchBar
                  ? TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'ابحث في المدفوعات...',
                        hintStyle: const TextStyle(color: AppColors.gray500),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _showSearchBar = false;
                              _searchController.clear();
                            });
                          },
                        ),
                      ),
                      style: const TextStyle(color: AppColors.black),
                      onChanged: (value) {
                        // TODO: تطبيق البحث
                        context.read<PaymentCubit>().searchPayments(value);
                      },
                    )
                  : const Text(
                      'إدارة المدفوعات',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppColors.paleGold,
                      ),
                    ),
              backgroundColor: AppColors.deepRed,
              floating: true,
              snap: true,
              pinned: true,
              elevation: 4,
              forceElevated: innerBoxIsScrolled,
              actions: [
                if (!_showSearchBar)
                  IconButton(
                    icon: const Icon(Icons.search, color: AppColors.paleGold),
                    onPressed: () {
                      setState(() {
                        _showSearchBar = true;
                      });
                    },
                  ),
              ],
            ),

            // قسم الإحصائيات
            const SliverToBoxAdapter(child: PaymentStatsSection()),

            // التصفية السريعة
            const SliverToBoxAdapter(child: PaymentFilters()),

            // عنوان قائمة المدفوعات
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
                      'قائمة المدفوعات',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.deepRed,
                      ),
                    ),
                    BlocBuilder<PaymentCubit, PaymentState>(
                      builder: (context, state) {
                        if (state is PaymentLoaded) {
                          return Text(
                            '${state.payments.length} دفعة',
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
        body: const PaymentsList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPaymentDialog,
        backgroundColor: AppColors.deepRed,
        foregroundColor: AppColors.paleGold,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 28),
      ),
      // زر التحميل لأعلى
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomAppBar(),
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
                onPressed: () {
                  // TODO: تطبيق تصدير البيانات
                  _showExportOptions();
                },
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

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'تصدير البيانات',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.deepRed,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(
                  Icons.picture_as_pdf,
                  color: AppColors.deepRed,
                ),
                title: const Text(
                  'تصدير كـ PDF',
                  style: TextStyle(color: AppColors.gold),
                ),
                subtitle: const Text(
                  'تصدير قائمة المدفوعات بصيغة PDF',
                  style: TextStyle(color: AppColors.gold),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: تطبيق تصدير PDF
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.table_chart,
                  color: AppColors.deepRed,
                ),
                title: const Text(
                  'تصدير كـ Excel',
                  style: TextStyle(color: AppColors.gold),
                ),
                subtitle: const Text(
                  'تصدير البيانات بصيغة Excel',
                  style: TextStyle(color: AppColors.gold),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: تطبيق تصدير Excel
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'إلغاء',
                  style: TextStyle(color: AppColors.deepRed),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
