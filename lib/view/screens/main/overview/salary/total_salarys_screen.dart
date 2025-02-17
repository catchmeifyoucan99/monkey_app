import 'package:expense_personal/widgets/circle_total_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../widgets/total_tab.dart';
import '../../../../../widgets/week_calendar_widget.dart';

class TotalSalarysScreen extends StatefulWidget {
  const TotalSalarysScreen({super.key});

  @override
  _TotalSalarysScreenState createState() => _TotalSalarysScreenState();
}

class _TotalSalarysScreenState extends State<TotalSalarysScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _selectedDay;

  final Map<DateTime, List<String>> _events = {
    DateTime(2025, 2, 3): ['Lương chính: 10 triệu', 'Thưởng KPI: 1 triệu'],
    DateTime(2025, 2, 5): ['Thưởng: 2 triệu'],
    DateTime(2025, 2, 10): ['Lương phụ: 5 triệu', 'Hoa hồng: 500k'],
    DateTime(2025, 2, 11): ['Tiền thưởng: 1 triệu'],
    DateTime(2025, 2, 15): ['Tiền phụ cấp: 3 triệu'],
  };

  List<Map<String, dynamic>> _processEvents(List<String> events, DateTime date) {
    return events.map((event) {
      final parts = event.split(': ');
      if (parts.length != 2) return null;

      final amountString = parts[1].replaceAll(RegExp(r'[^0-9]'), '');
      final amount = int.tryParse(amountString) ?? 0 * 1000;

      return {
        'description': parts[0],
        'amount': amount,
        'type': 'income',
        'date': date,
      };
    }).where((item) => item != null).cast<Map<String, dynamic>>().toList();
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<String> _getEventsForDay(DateTime day) {
    final normalizedDate = DateTime(day.year, day.month, day.day);
    return _events[normalizedDate] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tổng Thu Nhập',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: () => context.go('/home'),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Color(0xFFB0B8BF), width: 1),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.black,
                  size: 18
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 35),
            WeekCalendarWidget(
              initialDate: DateTime.now(),
              selectedDay: _selectedDay,
              onWeekChanged: (newWeek) {
                setState(() {
                });
              },
              onDaySelected: (date) {
                final normalizedDate = DateTime(date.year, date.month, date.day);
                setState(() {
                  _selectedDay = normalizedDate;
                });
              },
            ),
            const SizedBox(height: 40),
            TotalCircle(total: '1,000,000'),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "You have spent total 60% of your budget",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF242D35),
                ),
              ),
            ),
            const SizedBox(height: 25),
            _buildTabSection(),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFeaedf0),
    );
  }

  Widget _buildTabSection() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          Expanded(
            child: _selectedDay == null
                ? const Center(child: Text('Chọn ngày để xem chi tiết thu nhập.'))
                : TotalTab(
              tabController: _tabController,
              spendsData: _processEvents(
                _getEventsForDay(_selectedDay!),
                _selectedDay!,
              ),
              categoriesData: [],
            ),
          ),
        ],
      ),
    );
  }
}