import 'package:expense_personal/widgets/overview_card.dart';
import 'package:expense_personal/widgets/overview_tab.dart';
import 'package:flutter/material.dart';
import '../../../../cores/interfaces/TransactionRepository.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key, required this.transactionRepository});

  final TransactionRepository transactionRepository;

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tổng quan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            OverviewCardList(transactionRepository: widget.transactionRepository),
            const SizedBox(height: 40),
            OverviewTab(tabController: _tabController),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFeaedf0),
    );
  }
}
