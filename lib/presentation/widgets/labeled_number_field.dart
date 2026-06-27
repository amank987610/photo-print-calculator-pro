import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Numeric text field with a floating label + optional suffix (unit /
/// currency symbol). Emits parsed double on every change - no submit
/// button, calculations update live as required by spec.
class LabeledNumberField extends StatelessWidget {
  final String label;
  final String? suffixText;
  final IconData? icon;
  final TextEditingController controller;
  final ValueChanged<double> onChanged;
  final bool allowDecimal;

  const LabeledNumberField({
    super.key,
    required this.label,
    required this.controller,
    required this.onChanged,
    this.suffixText,
    this.icon,
    this.allowDecimal = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
      inputFormatters: [
        allowDecimal
            ? FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}'))
            : FilteringTextInputFormatter.digitsOnly,
      ],
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        suffixText: suffixText,
      ),
      onChanged: (value) {
        final parsed = double.tryParse(value) ?? 0;
        onChanged(parsed);
      },
    );
  }
}
