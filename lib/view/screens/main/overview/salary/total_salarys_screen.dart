import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../untils/format_utils.dart';

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
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1D3A58).withOpacity(0.12),
                  offset: const Offset(0, 8),
                  blurRadius: 64,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _focusedWeek = _focusedWeek.subtract(const Duration(days: 7));
                        });
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFFB0B8BF), width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.chevron_left, size: 28, color: Colors.black),
                      ),
                    ),
                    Text(
                      DateFormat('MMMM - yyyy').format(_focusedWeek),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _focusedWeek = _focusedWeek.add(const Duration(days: 7));
                        });
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFFB0B8BF), width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.chevron_right, size: 28, color: Colors.black),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: daysInWeek.map((date) {
                    final isSelected = _selectedDay != null &&
                        _selectedDay!.year == date.year &&
                        _selectedDay!.month == date.month &&
                        _selectedDay!.day == date.day;

                    final bool isFutureDay = date.isAfter(DateTime.now());
                    final String shortDay = DateFormat('EEE').format(date).substring(0, 2);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDay = date;
                        });
                      },
                      child: Column(
                        children: [
                          Text(
                            shortDay,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.teal : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              '${date.day}',
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : (isFutureDay ? const Color(0xFFB0B8BF) : Colors.black), // Chỉ đổi màu ngày
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 45),

//////Total Circle//////
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Color(0xFFEEF0F1),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Color(0xFFE5E7E9),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.teal,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      totalExpense,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'VNĐ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
