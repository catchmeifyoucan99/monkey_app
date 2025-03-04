import 'package:expense_personal/providers/auth_provider.dart';
import 'package:expense_personal/view/screens/account/register_screen.dart';
import 'package:expense_personal/view/screens/main/add/add_expense.dart';
import 'package:expense_personal/view/screens/main/add/add_from_camera.dart';
import 'package:expense_personal/view/screens/main/add/add_salary.dart';
import 'package:expense_personal/view/screens/main/add/add_screen.dart';
import 'package:expense_personal/view/screens/main/add/more_transaction_screen.dart';
import 'package:expense_personal/view/screens/main/introduce_screen.dart';
import 'package:expense_personal/view/screens/main/main_screen.dart';
import 'package:expense_personal/view/screens/main/overview/overview_screen.dart';
import 'package:expense_personal/view/screens/main/overview/expense/total_expenses_screen.dart';
import 'package:expense_personal/view/screens/main/overview/salary/total_salarys_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkIfFirstTime(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Monkey',
          theme: ThemeData(primarySwatch: Colors.blue),
          routerConfig: _router(snapshot.data ?? true),
        );
      },
    );
  }

  Future<bool> _checkIfFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
    if (isFirstTime) {
      await prefs.setBool('isFirstTime', false);
    }
    return isFirstTime;
  }

  GoRouter _router(bool isFirstTime) {
    return GoRouter(
      initialLocation: isFirstTime ? '/introduce' : '/login',
      routes: [
        GoRoute(path: '/',
          builder: (context, state) => const MainScreen(),
        ),
        GoRoute(
          path: '/introduce',
          builder: (context, state) => const IntroduceScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const MainScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const MainScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/overView',
          builder: (context, state) => const OverviewScreen(),
        ),
        GoRoute(
          path: '/totalSalary',
          builder: (context, state) => const TotalSalarysScreen(),
        ),
        GoRoute(
          path: '/totalExpense',
          builder: (context, state) => const TotalExpensesScreen(),
        ),
        GoRoute(
          path: '/addScreen',
          builder: (context, state) => const AddScreen(),
        ),
        GoRoute(
          path: '/addSalary',
          builder: (context, state) => const AddSalaryScreen(),
        ),
        GoRoute(
          path: '/addExpense',
          builder: (context, state) => const AddExpenseScreen(),
        ),
        GoRoute(
          path: '/addCamera',
          builder: (context, state) => CameraScreen(),
        ),
        GoRoute(
          path: '/moreTransactions',
          builder: (context, state) => const MoreTransactionScreen(),
        ),

      ],
    );
  }
}
