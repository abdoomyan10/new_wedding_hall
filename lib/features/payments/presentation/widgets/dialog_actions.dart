// features/payments/presentation/widgets/dialog_actions.dart
import 'package:flutter/material.dart';

class DialogActions extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const DialogActions({
    super.key,
    required this.isEditing,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: onCancel,
          child: const Text('إلغاء'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: onConfirm,
          child: Text(isEditing ? 'تحديث' : 'إضافة'),
        ),
      ],
    );
  }
}