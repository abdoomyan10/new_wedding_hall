// features/payments/presentation/widgets/dialog_header.dart
import 'package:flutter/material.dart';

class DialogHeader extends StatelessWidget {
  final bool isEditing;

  const DialogHeader({super.key, required this.isEditing});

  @override
  Widget build(BuildContext context) {
    return Text(isEditing ? 'تعديل الدفعة' : 'إضافة دفعة جديدة');
  }
}