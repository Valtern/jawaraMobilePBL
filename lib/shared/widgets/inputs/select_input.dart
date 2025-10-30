import 'package:flutter/material.dart';

class SelectInput<T> extends StatelessWidget {
  const SelectInput({
    super.key,
    required this.label,
    required this.items,
    this.value,
    this.prefixIcon,
    this.onChanged,
    this.dropdownColor,
  });

  final String label;
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final Widget? prefixIcon;
  final ValueChanged<T?>? onChanged;
  final Color? dropdownColor;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      dropdownColor: dropdownColor ?? Colors.white,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        labelText: label,
        prefixIcon: prefixIcon,
      ),
    );
  }
}
