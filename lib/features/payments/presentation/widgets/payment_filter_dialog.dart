// features/payments/presentation/widgets/payment_filter_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';

class PaymentFilterDialog extends StatefulWidget {
  const PaymentFilterDialog({super.key});

  @override
  State<PaymentFilterDialog> createState() => _PaymentFilterDialogState();
}

class _PaymentFilterDialogState extends State<PaymentFilterDialog> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String? _selectedStatus = 'all';
  String? _selectedPaymentMethod = 'all';

  final List<Map<String, dynamic>> _statuses = [
    {'value': 'all', 'text': 'الكل'},
    {'value': 'completed', 'text': 'مكتمل'},
    {'value': 'pending', 'text': 'معلق'},
    {'value': 'failed', 'text': 'فاشل'},
  ];

  final List<Map<String, dynamic>> _paymentMethods = [
    {'value': 'all', 'text': 'الكل'},
    {'value': 'cash', 'text': 'نقدي'},
    {'value': 'bank_transfer', 'text': 'تحويل بنكي'},
    {'value': 'credit_card', 'text': 'بطاقة ائتمان'},
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تصفية المدفوعات'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // فلترة حسب التاريخ
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'الفترة الزمنية:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              title: const Text('من تاريخ'),
              subtitle: Text(DateFormat('yyyy-MM-dd').format(_startDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (selectedDate != null) {
                  setState(() {
                    _startDate = selectedDate;
                  });
                }
              },
            ),
            ListTile(
              title: const Text('إلى تاريخ'),
              subtitle: Text(DateFormat('yyyy-MM-dd').format(_endDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _endDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (selectedDate != null) {
                  setState(() {
                    _endDate = selectedDate;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // فلترة حسب الحالة
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'حالة الدفع:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DropdownButtonFormField<String?>(
              value: _selectedStatus,
              items: _statuses.map((status) {
                return DropdownMenuItem<String?>(
                  value: status['value'],
                  child: Text(status['text']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // فلترة حسب طريقة الدفع
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'طريقة الدفع:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DropdownButtonFormField<String?>(
              value: _selectedPaymentMethod,
              items: _paymentMethods.map((method) {
                return DropdownMenuItem<String?>(
                  value: method['value'],
                  child: Text(method['text']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: تطبيق الفلترة
            Navigator.of(context).pop();
          },
          child: const Text('تطبيق الفلترة'),
        ),
      ],
    );
  }
}