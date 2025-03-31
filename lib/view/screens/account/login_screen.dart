import 'dart:developer' as dev;
import 'package:expense_personal/widgets/auth/ui/logo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../cores/providers/auth_provider.dart';
import '../../../widgets/auth/ui/input_field.dart';
import '../../../widgets/auth/ui/login_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;

  void login() async {
    final authProvider = context.read<AuthProvider>();

    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    try {
      bool success = await authProvider.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (success) {
        String userName = authProvider.user?.name ?? "Người dùng";

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Xin chào $userName"),
          ),
        );

        context.go('/home');
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sai tài khoản hoặc mật khẩu!')),
        );
      }
    } catch (e) {
      dev.log("Đăng nhập lỗi $e", name: "LoginScreen");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Logo(),
              const SizedBox(height: 40),

              InputField(
                controller: emailController,
                label: 'Email',
                icon: Icons.email,
                isPassword: false,
              ),
              const SizedBox(height: 20),

              InputField(
                controller: passwordController,
                label: 'Mật khẩu',
                icon: Icons.lock,
                isPassword: true,
                isPasswordVisible: isPasswordVisible,
                togglePasswordVisibility: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
              ),
              const SizedBox(height: 30),

              LoginButton(onPressed: login),
              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  dev.log("Quên mật khẩu", name: "LoginScreen");
                },
                child: const Text("Quên mật khẩu"),
              ),

              TextButton(
                onPressed: () => context.go('/register'),
                child: const Text("Chưa có tài khoản? Đăng ký"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
