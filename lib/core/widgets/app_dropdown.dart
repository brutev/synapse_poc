import 'package:flutter/material.dart';

class AppDropdown extends StatelessWidget {
  const AppDropdown({
    required this.items,
    required this.value,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final List<String> items;
  final String? value;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items
          .map(
            (String item) =>
                DropdownMenuItem<String>(value: item, child: Text(item)),
          )
          .toList(),
      onChanged: enabled ? onChanged : null,
      decoration: const InputDecoration(border: OutlineInputBorder()),
    );
  }
}
