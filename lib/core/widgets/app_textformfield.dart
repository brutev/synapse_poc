import 'package:flutter/material.dart';

class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    required this.initialValue,
    required this.label,
    required this.enabled,
    required this.onChanged,
    this.keyboardType,
    this.requiredField = false,
    super.key,
  });

  final String initialValue;
  final String label;
  final bool enabled;
  final bool requiredField;
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: requiredField ? '$label *' : label,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }
}
