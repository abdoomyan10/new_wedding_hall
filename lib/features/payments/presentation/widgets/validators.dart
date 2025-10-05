// features/payments/presentation/widgets/validators.dart
class PaymentValidators {
  static String? requiredValidator(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال $fieldName';
    }
    return null;
  }

  static String? amountValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال المبلغ';
    }
    if (double.tryParse(value) == null) {
      return 'يرجى إدخال مبلغ صحيح';
    }
    return null;
  }
}