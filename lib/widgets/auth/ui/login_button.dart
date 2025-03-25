import 'package:flutter/material.dart';
import '../../custom_button.dart';

class LoginButton extends StatelessWidget {
  final VoidCallback onPressed;

  const LoginButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      label: 'Đăng nhập',
      backgroundColor: Colors.teal,
      onPressed: onPressed,
      borderRadius: 12.0,
      color: Colors.white,
      fontSize: 18,
      horizontal: 24,
      vertical: 14,
    );
  }
}