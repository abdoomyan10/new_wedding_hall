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
    _amountController.text = payment.amount.toStringAsFixed(0);
    _selectedPaymentMethod = payment.paymentMethod;
    _selectedStatus = payment.status;
    _selectedDate = payment.paymentDate;
    _notesController.text = payment.notes;
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _eventNameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.paymentToEdit != null;

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'تعديل الدفعة' : 'إضافة دفعة جديدة',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _clientNameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم العميل',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
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
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'تاريخ الدفع',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'ملاحظات (اختياري)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(isEditing ? 'تحديث' : 'إضافة'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final payment = PaymentEntity(
        id: widget.paymentToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        eventId: widget.paymentToEdit?.eventId ?? 'event_${DateTime.now().millisecondsSinceEpoch}',
        clientName: _clientNameController.text,
        eventName: _eventNameController.text,
        amount: double.parse(_amountController.text),
        paymentMethod: _selectedPaymentMethod,
        status: _selectedStatus,
        paymentDate: _selectedDate,
        notes: _notesController.text,
        createdAt: widget.paymentToEdit?.createdAt ?? DateTime.now(),
      );

      if (widget.paymentToEdit != null) {
        context.read<PaymentCubit>().updatePayment(payment);
      } else {
        context.read<PaymentCubit>().addPayment(payment);
      }

      Navigator.of(context).pop();
    }
  }
}