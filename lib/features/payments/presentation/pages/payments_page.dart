// features/payments/presentation/pages/payments_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/payment_cubit.dart';
import '../widgets/add_payment_dialog.dart';

import '../widgets/payment_filters.dart';
import '../widgets/payment_stats_section.dart';
import '../widgets/payments_list.dart';
import 'saved_payments_reports_page.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final ScrollController _scrollController = ScrollController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'إدارة المدفوعات',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      backgroundColor: Colors.blue.shade700,
      foregroundColor: Colors.white,
      elevation: 2,
      actions: [
        // زر التقارير المحفوظة
        IconButton(
          icon: const Icon(Icons.folder),
          tooltip: 'التقارير المحفوظة',
          onPressed: () => _navigateToSavedReports(context),
        ),
        // زر تصدير PDF مع حفظ على الجهاز
        PopupMenuButton<String>(
          icon: const Icon(Icons.picture_as_pdf),
          tooltip: 'تصدير PDF',
          onSelected: (value) {
            if (value == 'save_report') {
              _savePdfReport(context);
            } else if (value == 'print_report') {
              _printPdfReport(context);
            } else if (value == 'saved_reports') {
              _navigateToSavedReports(context);
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
          icon: const Icon(Icons.refresh),
          tooltip: 'تحديث البيانات',
          onPressed: () => context.read<PaymentCubit>().loadPayments(),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          // قسم الإحصائيات
          const SliverToBoxAdapter(
            child: PaymentStatsSection(),
          ),

          // التصفية السريعة
          const SliverToBoxAdapter(
            child: PaymentFilters(),
          ),

          // عنوان قائمة المدفوعات
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'قائمة المدفوعات',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  BlocBuilder<PaymentCubit, PaymentState>(
                    builder: (context, state) {
                      if (state is PaymentLoaded) {
                        return Text(
                          '${state.payments.length} دفعة',
                          style: const TextStyle(
                            color: Colors.grey,
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
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: _showAddPaymentDialog,
      backgroundColor: Colors.blue.shade700,
      foregroundColor: Colors.white,
      child: const Icon(Icons.add, size: 28),
    );
  }

  void _savePdfReport(BuildContext context) {
    context.read<PaymentCubit>().generateAndSavePdfReport();

    // إظهار رسالة تأكيد
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('جاري حفظ تقرير PDF...'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _printPdfReport(BuildContext context) {
    context.read<PaymentCubit>().generatePdfReport();

    // إظهار رسالة تأكيد
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('جاري إعداد التقرير للطباعة...'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToSavedReports(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SavedPaymentsReportsPage()),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}