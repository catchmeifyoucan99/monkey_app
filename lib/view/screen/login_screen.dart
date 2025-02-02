import 'package:flutter/material.dart';
import 'package:expense_personal/widget/custom_button.dart';
import 'register_screen.dart';
import 'package:expense_personal/widget/input_decoration.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;

  void login() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
    } else {
      print('Email: $email, Password: $password');
      // Thực hiện đăng nhập tại đây
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

            // Email field
            TextField(
              controller: emailController,
              decoration: customInputDecoration('Email', Icons.email),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            // Password field
            TextField(
              controller: passwordController,
              decoration: customInputDecoration(
                'Mật khẩu',
                Icons.lock,
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF242D35),
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !isPasswordVisible,
            ),
            const SizedBox(height: 30),

            // Login button
            CustomButton(
              label: 'Đăng nhập',
              backgroundColor: const Color(0xFF0E33F3),
              onPressed: login,
              borderRadius: 12.0,
              color: Colors.white,
              fontSize: 18,
              horizontal: 24,
              vertical: 14,
            ),

            const SizedBox(height: 20),

            // Forgot Password
            TextButton(
              onPressed: () {
                print("Quên mật khẩu");
              },
              child: const Text("Quên mật khẩu"),
            ),

            // Register navigation
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
              },
              child: const Text("Chưa có tài khoản? Đăng ký"),
            ),
          ],
        ),
      ),
    );
  }
}
