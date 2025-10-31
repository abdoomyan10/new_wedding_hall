// features/expenses/presentation/widgets/add_expense_dialog.dart
import 'dart:ui' as ui; // إضافة هذا الاستيراد

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:new_wedding_hall/core/constants/app_colors.dart';
import '../cubit/expense_cubit.dart';
import '../../domain/entities/expense_entity.dart';

class AddExpenseDialog extends StatefulWidget {
  const AddExpenseDialog({super.key});

  @override
  _AddExpenseDialogState createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _workerNameController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'مواد';

  final List<String> _categories = ['مواد', 'عمالة', 'صيانة', 'خدمات', 'أخرى'];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl, // استخدام ui.TextDirection
      child: AlertDialog(
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.add_circle, color: AppColors.deepRed),
            SizedBox(width: 8),
            Text(
              'إضافة تكلفة جديدة',
              style: TextStyle(
                color: AppColors.gold,
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDescriptionField(),
                const SizedBox(height: 16),
                _buildAmountField(),
                const SizedBox(height: 16),
                _buildWorkerField(),
                const SizedBox(height: 16),
                _buildCategoryField(),
                const SizedBox(height: 16),
                _buildDateField(),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'إلغاء',
              style: TextStyle(
                color: AppColors.gold,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _saveExpense,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepRed,
              foregroundColor: AppColors.gold,
            ),
            child: const Text(
              'حفظ التكلفة',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      textDirection: ui.TextDirection.rtl, // استخدام ui.TextDirection
      decoration: const InputDecoration(
        floatingLabelStyle: TextStyle(color: AppColors.deepRed),
        labelText: 'وصف التكلفة',
        prefixIcon: Icon(Icons.description, color: AppColors.deepRed),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.deepRed),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.deepRed),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى إدخال وصف التكلفة';
        }
        return null;
      },
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      textDirection: ui.TextDirection.rtl, // استخدام ui.TextDirection
      decoration: const InputDecoration(
        floatingLabelStyle: TextStyle(color: AppColors.deepRed),
        labelText: 'المبلغ (ر.س)',
        prefixIcon: Icon(Icons.attach_money, color: AppColors.deepRed),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.deepRed),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.deepRed),
        ),
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
    );
  }

  Widget _buildWorkerField() {
    return TextFormField(
      controller: _workerNameController,
      textDirection: ui.TextDirection.rtl, // استخدام ui.TextDirection
      decoration: const InputDecoration(
        floatingLabelStyle: TextStyle(color: AppColors.deepRed),
        labelText: 'اسم العامل',
        prefixIcon: Icon(Icons.person, color: AppColors.deepRed),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.deepRed),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.deepRed),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى إدخال اسم العامل';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryField() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: const InputDecoration(
        floatingLabelStyle: TextStyle(color: AppColors.deepRed),
        labelText: 'الفئة',
        prefixIcon: Icon(Icons.category, color: AppColors.deepRed),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.deepRed),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.deepRed),
        ),
      ),
      items: _categories.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(
            category,
            style: const TextStyle(fontFamily: 'Tajawal'),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedCategory = newValue!;
        });
      },
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _selectDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          floatingLabelStyle: TextStyle(color: AppColors.deepRed),
          labelText: 'تاريخ التكلفة',
          prefixIcon: Icon(Icons.calendar_today, color: AppColors.deepRed),
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
            Text(
              DateFormat('yyyy-MM-dd').format(_selectedDate),
              style: const TextStyle(fontFamily: 'Tajawal'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final expense = ExpenseEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        workerName: _workerNameController.text,
        category: _selectedCategory,
        createdAt: DateTime.now(),
        title: _descriptionController.text,
      );

      context.read<ExpenseCubit>().addExpense(expense);
      Navigator.pop(context);

      // إظهار رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'تم إضافة التكلفة بنجاح',
            style: TextStyle(fontFamily: 'Tajawal'),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _workerNameController.dispose();
    super.dispose();
  }
}