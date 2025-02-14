import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeekCalendarWidget extends StatefulWidget {
  final DateTime initialDate;
  final DateTime? selectedDay;
  final Function(DateTime) onWeekChanged;
  final Function(DateTime) onDaySelected;

  const WeekCalendarWidget({
    super.key,
    required this.initialDate,
    required this.onWeekChanged,
    required this.onDaySelected,
    this.selectedDay,
  });

  @override
  _WeekCalendarWidgetState createState() => _WeekCalendarWidgetState();
}

class _WeekCalendarWidgetState extends State<WeekCalendarWidget> {
  late DateTime _focusedWeek;

  @override
  void initState() {
    super.initState();
    _focusedWeek = widget.initialDate;
  }

  List<DateTime> _getDaysInWeek(DateTime week) {
    final startOfWeek = week.subtract(Duration(days: week.weekday - 1));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    final daysInWeek = _getDaysInWeek(_focusedWeek);

    return Container(
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
                  widget.onWeekChanged(_focusedWeek);
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
                  widget.onWeekChanged(_focusedWeek);
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
              final bool isSelected = widget.selectedDay != null &&
                  widget.selectedDay!.year == date.year &&
                  widget.selectedDay!.month == date.month &&
                  widget.selectedDay!.day == date.day;

              final bool isToday = widget.selectedDay == null &&
                  date.year == DateTime.now().year &&
                  date.month == DateTime.now().month &&
                  date.day == DateTime.now().day;

              final bool isFutureDay = date.isAfter(DateTime.now());
              final String shortDay = DateFormat('EEE').format(date).substring(0, 2);

              return GestureDetector(
                onTap: () {
                  final normalizedDate = DateTime(date.year, date.month, date.day);
                  widget.onDaySelected(normalizedDate);
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
                        color: isSelected || isToday ? Colors.teal : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          color: isSelected || isToday
                              ? Colors.white
                              : (isFutureDay ? const Color(0xFFB0B8BF) : Colors.black),
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
    );
  }
}