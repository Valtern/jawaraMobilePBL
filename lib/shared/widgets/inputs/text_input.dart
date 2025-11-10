import 'package:flutter/material.dart';

class TextInput extends StatelessWidget {
  const TextInput({
    super.key,
    required this.label,
    this.controller,
    this.prefixIcon,
    this.keyboardType,
    this.onChanged,
    this.maxLines = 1,
    this.onTap,
    this.readOnly = false,
  });

  final String label;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final VoidCallback? onTap;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      maxLines: maxLines,
      onTap: onTap,
      readOnly: readOnly,
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