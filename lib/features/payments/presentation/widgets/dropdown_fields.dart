// features/payments/presentation/widgets/dropdown_fields.dart
import 'package:flutter/material.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final T value;
  final List<Map<String, dynamic>> items;
  final String labelText;
  final Function(T?) onChanged;
  final String Function(Map<String, dynamic> item) displayText;

  const CustomDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.labelText,
    required this.onChanged,
    required this.displayText,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item['value'] as T,
          child: Text(displayText(item)),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}