import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blute_mobile/core/theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final ValueChanged<String>? onChanged;

  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final String? prefixText;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.onChanged,
    this.inputFormatters,
    this.maxLength,
    this.prefixText,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        counterText: '',
        prefixText: prefixText,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 30,
        ),
      ),
      inputFormatters: inputFormatters,
      maxLength: maxLength,
    );
  }
}
