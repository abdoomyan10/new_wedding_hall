// features/payments/presentation/widgets/payments_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../cubit/payment_cubit.dart';
import 'payment_card.dart';

class PaymentsList extends StatelessWidget {
  const PaymentsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentCubit, PaymentState>(
      builder: (context, state) {
        if (state is PaymentLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('جاري تحميل المدفوعات...'),
              ],
            ),
          );
        } else if (state is PaymentLoaded) {
          if (state.payments.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment, size: 64, color: AppColors.gray500),
                  SizedBox(height: 16),
                  Text(
                    'لا توجد حجوزات',
                    style: TextStyle(fontSize: 18, color: AppColors.gray500),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'انقر على زر + لإضافة حجز جديد',
                    style: TextStyle(fontSize: 14, color: AppColors.gray500),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<PaymentCubit>().loadPayments();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.payments.length,
              itemBuilder: (context, index) {
                final payment = state.payments[index];
                return PaymentCard(payment: payment);
              },
            ),
          );
        } else if (state is PaymentError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: const TextStyle(fontSize: 16, color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<PaymentCubit>().loadPayments();
                  },
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }
        return const Center(child: Text('مرحباً بك في إدارة الحجوزات '));
      },
    );
  }
}