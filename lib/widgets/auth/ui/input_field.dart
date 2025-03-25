import 'package:flutter/material.dart';
import '../../input_decoration.dart';

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final bool? isPasswordVisible;
  final VoidCallback? togglePasswordVisibility;

  const InputField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.isPassword,
    this.isPasswordVisible,
    this.togglePasswordVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: customInputDecoration(
        label,
        icon,
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            isPasswordVisible! ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF242D35),
          ),
          onPressed: togglePasswordVisibility,
        )
            : null,
      ),
      obscureText: isPassword ? !(isPasswordVisible ?? false) : false,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập $label';
        }
        return null;
      },
    );
  }
}