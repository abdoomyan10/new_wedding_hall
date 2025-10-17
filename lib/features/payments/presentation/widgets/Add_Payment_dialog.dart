// features/payments/presentation/widgets/add_payment_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/payment_entity.dart';
import '../cubit/payment_cubit.dart';

class AddPaymentDialog extends StatefulWidget {
  final PaymentEntity? paymentToEdit;

  const AddPaymentDialog({super.key, this.paymentToEdit});

  @override
  State<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _eventNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedPaymentMethod = 'cash';
  String _selectedStatus = 'completed';
  DateTime _selectedDate = DateTime.now();

  final List<Map<String, dynamic>> _paymentMethods = [
    {'value': 'cash', 'text': 'نقدي'},
    {'value': 'bank_transfer', 'text': 'تحويل بنكي'},
    {'value': 'credit_card', 'text': 'بطاقة ائتمان'},
  ];

  final List<Map<String, dynamic>> _statuses = [
    {'value': 'completed', 'text': 'مكتمل'},
    {'value': 'pending', 'text': 'معلق'},
    {'value': 'failed', 'text': 'فاشل'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.paymentToEdit != null) {
      _initializeFormWithPaymentData();
    }
  }

  void _initializeFormWithPaymentData() {
    final payment = widget.paymentToEdit!;
    _clientNameController.text = payment.clientName;
    _eventNameController.text = payment.eventName;
    _amountController.text = payment.amount.toString();
    _selectedPaymentMethod = payment.paymentMethod;
    _selectedStatus = payment.status;
    _selectedDate = payment.paymentDate;
    _notesController.text = payment.notes;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.paymentToEdit != null;

    return AlertDialog(
      title: Text(isEditing ? 'تعديل الدفعة' : 'إضافة دفعة جديدة'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _clientNameController,
                decoration: const InputDecoration(
                  labelText: 'اسم العميل',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال اسم العميل';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _eventNameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الحفلة',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال اسم الحفلة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'المبلغ (ر.س)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال المبلغ';
                  }
                  if (double.tryParse(value) == null) {
                    return 'يرجى إدخال مبلغ صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                items: _paymentMethods.map((method) {
                  return DropdownMenuItem<String>(
                    value: method['value'] as String,
                    child: Text(method['text'] as String),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPaymentMethod = value;
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'طريقة الدفع',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                items: _statuses.map((status) {
                  return DropdownMenuItem<String>(
                    value: status['value'] as String,
                    child: Text(status['text'] as String),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'حالة الدفع',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات (اختياري)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('تاريخ الدفع'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      _selectedDate = selectedDate;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final payment = PaymentEntity(
                id: isEditing ? widget.paymentToEdit!.id : DateTime.now().millisecondsSinceEpoch.toString(),
                eventId: isEditing ? widget.paymentToEdit!.eventId : 'event_${DateTime.now().millisecondsSinceEpoch}',
                eventName: _eventNameController.text,
                clientName: _clientNameController.text,
                amount: double.parse(_amountController.text),
                paymentDate: _selectedDate,
                paymentMethod: _selectedPaymentMethod,
                status: _selectedStatus,
                notes: _notesController.text,
                createdAt: isEditing ? widget.paymentToEdit!.createdAt : DateTime.now(),
              );

              if (isEditing) {
                context.read<PaymentCubit>().updatePayment(payment);
              } else {
                context.read<PaymentCubit>().addPayment(payment);
              }

              Navigator.of(context).pop();
            }
          },
          child: Text(isEditing ? 'تحديث' : 'إضافة'),
        ),
      ],
    );
  }
}