import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ExpenseBarChart extends StatelessWidget {
  final Map<String, double> categoryData;
  final Color primaryColor;
  final Color secondaryColor;

  const ExpenseBarChart({
    Key? key,
    required this.categoryData,
    this.primaryColor = Colors.blueAccent,
    this.secondaryColor = Colors.lightBlueAccent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = categoryData.keys.toList();
    final values = categoryData.values.toList();

    if (values.isEmpty) {
      return const Center(
        child: Text('Không có dữ liệu chi tiêu theo danh mục'),
      );
    }

    final maxValue = values.reduce((a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.4, // Giới hạn chiều cao
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Quan trọng: Đặt mainAxisSize thành min
          children: [
            const Text(
              'Chi tiêu theo danh mục',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded( // Sử dụng Expanded cho biểu đồ
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValue * 1.2,
                  minY: 0,
                  barGroups: categories.asMap().entries.map((entry) {
                    final index = entry.key;
                    final category = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: categoryData[category]!,
                          color: primaryColor,
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < categories.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                categories[index],
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            NumberFormat.compactCurrency(
                              locale: 'vi_VN',
                              symbol: '₫',
                            ).format(value),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  gridData: FlGridData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}