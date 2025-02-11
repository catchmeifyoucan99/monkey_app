import 'package:expense_personal/widgets/circle_total_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../untils/format_utils.dart';
import '../../../../../widgets/week_calendar_widget.dart';

class TotalSalarysScreen extends StatefulWidget {
  const TotalSalarysScreen({super.key});

  @override
  _TotalSalarysScreenState createState() => _TotalSalarysScreenState();
}

class _TotalSalarysScreenState extends State<TotalSalarysScreen> {
  DateTime _focusedWeek = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, List<String>> _events = {
    DateTime(2024, 2, 3): ['Lương chính: 10 triệu'],
    DateTime(2024, 2, 5): ['Thưởng: 2 triệu'],
    DateTime(2024, 2, 10): ['Lương phụ: 5 triệu'],
  };


  List<String> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  List<DateTime> _getDaysInWeek(DateTime week) {
    final startOfWeek = week.subtract(Duration(days: week.weekday - 1));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    final daysInWeek = _getDaysInWeek(_focusedWeek);
    final String totalExpense = formatCurrency(5000000, includeCurrency: false);

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
            onTap: () => context.go('/overView'),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Color(0xFFB0B8BF), width: 1),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.black,
                  size: 18
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 35),

//////Calender//////
          WeekCalendarWidget(
            initialDate: DateTime.now(),
            selectedDay: _selectedDay,
            onWeekChanged: (newWeek) {
              setState(() {
                _focusedWeek = newWeek;
              });
            },
            onDaySelected: (selectedDate) {
              setState(() {
                _selectedDay = selectedDate;
              });
            },
          ),
          const SizedBox(height: 45),

//////Total Circle//////
          TotalCircle(total: '1,000,000'),
          const SizedBox(height: 16),

//////Comment//////
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 150,
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
            ],
          ),

//////TapBar//////
          Expanded(
            child: _selectedDay == null
                ? const Center(child: Text('Chọn ngày để xem chi tiết thu nhập.'))
                : ListView.builder(
              itemCount: _getEventsForDay(_selectedDay!).length,
              itemBuilder: (context, index) {
                final event = _getEventsForDay(_selectedDay!)[index];
                return ListTile(
                  leading: const Icon(Icons.monetization_on, color: Colors.teal),
                  title: Text(event),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
