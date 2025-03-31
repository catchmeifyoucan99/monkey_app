import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:expense_personal/widgets/input_decoration.dart';
import 'package:expense_personal/widgets/custom_button.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../cores/providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreen();
}

class _RegisterScreen extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void showSnackBarMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  bool isValidEmail(String email) {
    final RegExp regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  String? validateInput(String name, String email, String password, String confirmPassword) {
    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      return 'Vui lòng nhập đầy đủ thông tin';
    }
    if (!isValidEmail(email)) {
      return 'Email không đúng định dạng';
    }
    if (password.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    if (password != confirmPassword) {
      return 'Mật khẩu không khớp';
    }
    if (name.length < 3 || name.length > 18) {
      return 'Tên phải từ 3 đến 18 ký tự';
    }
    return null;
  }

  Future<void> register() async {
    final authProvider = context.read<AuthProvider>();
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    String? errorMessage = validateInput(name, email, password, confirmPassword);
    if (errorMessage != null) {
      showSnackBarMessage(errorMessage);
      return;
    }

    try {
      bool success = await authProvider.register(email, name, password);
      if (success) {
        showSnackBarMessage('Đăng ký thành công!');
        dev.log("UID người dùng: ${authProvider.user?.uid}", name: "RegisterScreen");

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) context.go('/login');
        });
      } else {
        showSnackBarMessage('Tài khoản đã được đăng ký!');
      }
    } catch (e) {
      showSnackBarMessage('Lỗi đăng ký: ${e.toString()}');
    }
  }

  Widget buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      decoration: customInputDecoration(label, icon),
      obscureText: obscureText,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  Image.asset('assets/images/logo.png', height: 110, width: 110),
                  const Text(
                    'monkey',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            buildInputField(label: 'Tên', icon: Icons.person, controller: nameController),
            const SizedBox(height: 20),

            buildInputField(label: 'Email', icon: Icons.email, controller: emailController),
            const SizedBox(height: 20),

            buildInputField(
              label: 'Mật khẩu',
              icon: Icons.lock,
              controller: passwordController,
              obscureText: true,
            ),
            const SizedBox(height: 20),

            buildInputField(
              label: 'Xác nhận mật khẩu',
              icon: Icons.lock,
              controller: confirmPasswordController,
              obscureText: true,
            ),
            const SizedBox(height: 30),

            CustomButton(
              label: 'Đăng ký',
              backgroundColor: Colors.teal,
              onPressed: register,
              borderRadius: 12.0,
              color: Colors.white,
              fontSize: 18,
              horizontal: 24,
              vertical: 14,
            ),
            const SizedBox(height: 20),

            TextButton(
              onPressed: () {
                if (mounted) context.go('/login');
              },
              child: const Text("Đã có tài khoản? Đăng nhập"),
            ),
          ],
        ),
      ),
    );
  }
}
