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
  bool isPasswordVisible = false;

  bool isValidEmail(String email) {
    final RegExp regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  Future<void> register() async {
    final authProvider = context.read<AuthProvider>();

    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    if (!isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email không đúng định dạng')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu phải có ít nhất 6 ký tự')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu không khớp')),
      );
      return;
    }

    if (name.length < 3 || name.length > 18) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tên phải từ 3 đến 18 ký tự')),
      );
      return;
    }

    try {
      bool success = await authProvider.register(email, name, password);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng ký thành công!')),
        );

        String? uid = authProvider.user?.uid;
        dev.log("UID người dùng: $uid", name: "RegisterScreen");

        Future.delayed(const Duration(seconds: 1), () {
          context.go('/login');
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tài khoản đã được đăng ký!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi đăng ký: ${e.toString()}')),
      );
    }
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
                  Image.asset(
                    'assets/images/logo.png',
                    height: 110,
                    width: 110,
                  ),
                  const Text(
                    'monkey',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            TextField(
              controller: nameController,
              decoration: customInputDecoration('Tên', Icons.person),
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 20),

            TextField(
              controller: emailController,
              decoration: customInputDecoration('Email', Icons.email),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              decoration: customInputDecoration(
                'Mật khẩu',
                Icons.lock,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            TextField(
              controller: confirmPasswordController,
              decoration: customInputDecoration(
                'Xác nhận mật khẩu',
                Icons.lock,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 30),

            CustomButton(
              label: 'Đăng ký',
              backgroundColor: const Color(0xFF0E33F3),
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
                if(mounted) return context.go('/login');
              },
              child: const Text("Đã có tài khoản? Đăng nhập"),
            ),
          ],
        ),
      ),
    );
  }
}
