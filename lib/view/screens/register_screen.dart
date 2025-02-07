import 'package:flutter/material.dart';
import 'package:expense_personal/widgets/input_decoration.dart';
import 'package:expense_personal/widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreen();
}

class _RegisterScreen extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isPasswordVisible = false;

  void register() {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
    } else if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu không khớp')),
      );
    } else {
      print('Tên: $name, Email: $email, Password: $password');
      // Thực hiện đăng ký tại đây
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
                Navigator.pop(context);
              },
              child: const Text("Đã có tài khoản? Đăng nhập"),
            ),
          ],
        ),
      ),
    );
  }
}
