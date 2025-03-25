import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_personal/cores/utils/getUserId.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:expense_personal/cores/providers/currency_provider.dart';
import '../cores/utils/format_utils.dart';

class OverviewCardList extends StatefulWidget {
  const OverviewCardList({super.key});

  @override
  _OverviewCardListState createState() => _OverviewCardListState();
}

class _OverviewCardListState extends State<OverviewCardList> {
  int totalIncome = 0;
  int totalExpense = 0;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    final String? userId = getCurrentUserId();
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    QuerySnapshot incomeQuery = await FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'income')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .get();

    QuerySnapshot expenseQuery = await FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'expense')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .get();

    int incomeTotal = 0;
    int expenseTotal = 0;

    for (var doc in incomeQuery.docs) {
      incomeTotal += (doc['amount'] as num).toInt();
    }

    for (var doc in expenseQuery.docs) {
      expenseTotal += (doc['amount'] as num).toInt();
    }

    setState(() {
      totalIncome = incomeTotal;
      totalExpense = expenseTotal;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return SizedBox(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        children: [
          _buildOverviewCard(
              context,
              'Tổng Thu Nhập',
              currencyProvider.convert(totalIncome.toDouble()),
              currencyProvider.currency,
              Colors.black,
              Icons.account_balance_wallet,
                  () => context.push('/totalSalary')
          ),
          _buildOverviewCard(
              context,
              'Tổng Chi Tiêu',
              currencyProvider.convert(totalExpense.toDouble()),
              currencyProvider.currency,
              Colors.white,
              Icons.shopping_cart,
                  () => context.push('/totalExpense')
          ),
          _buildOverviewCard(
              context,
              'Hàng Tháng',
              currencyProvider.convert((totalIncome - totalExpense).toDouble()),
              currencyProvider.currency,
              Colors.black,
              Icons.account_balance,
                  () => context.push('/totalMonthly')
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(
      BuildContext context,
      String title,
      double amount,
      String currencyCode,
      Color textColor,
      IconData icon,
      VoidCallback? onTap
      ) {
    String formattedAmount = formatCurrency(amount, currencyCode);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        width: MediaQuery.of(context).size.width * 0.35,
        decoration: BoxDecoration(
          color: textColor == Colors.black ? Colors.white : Colors.teal,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 1)],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Icon(icon, color: textColor, size: 22),
              const SizedBox(height: 10),
              Text(title, style: TextStyle(fontSize: 12, color: textColor)),
              const SizedBox(height: 35),
              Text(
                formattedAmount,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}