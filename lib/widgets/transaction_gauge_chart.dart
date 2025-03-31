import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ExpenseBarChart extends StatelessWidget {
  final Map<String, double> categoryData;
  final Color positiveColor;
  final Color negativeColor;
  final double barWidth;
  final double maxYMultiplier;

  const ExpenseBarChart({
    Key? key,
    required this.categoryData,
    this.positiveColor = Colors.teal,
    this.negativeColor = Colors.redAccent,
    this.barWidth = 22,
    this.maxYMultiplier = 1.2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = categoryData.keys.toList();
    final values = categoryData.values.toList();

    if (values.isEmpty) {
      return const Center(
        child: Text(
            'Không có dữ liệu chi tiêu theo danh mục',
            style: TextStyle(color: Colors.grey)),
      );
    }

    // Calculate max absolute value for scaling
    final maxAbsValue = values.fold(0.0, (max, value) =>
    value.abs() > max ? value.abs() : max);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'CHI TIÊU THEO DANH MỤC',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxAbsValue * maxYMultiplier,
                minY: 0, // All bars grow from 0
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) {
                      if (group.x == 1) return Colors.red;   // Nếu x = 1, màu đỏ
                      if (group.x == 2) return Colors.green; // Nếu x = 2, màu xanh lá
                      return Colors.blue;  // Mặc định màu xanh dương
                    },
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final category = categories[group.x.toInt()];
                      final originalValue = categoryData[category]!;
                      return BarTooltipItem(
                        '$category\n${NumberFormat.currency(
                            locale: 'vi_VN',
                            symbol: '₫',
                            decimalDigits: 0
                        ).format(originalValue)}',
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
                barGroups: categories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value;
                  final value = categoryData[category]!;
                  final isPositive = value >= 0;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: value.abs(), // Display absolute value
                        color: isPositive ? positiveColor : negativeColor,
                        width: barWidth,
                        borderRadius: BorderRadius.circular(6),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxAbsValue * maxYMultiplier,
                          color: Colors.grey.shade100,
                        ),
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
                              _shortenName(categories[index]),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 42,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: _calculateInterval(maxAbsValue),
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: Text(
                            NumberFormat.compactCurrency(
                              locale: 'vi_VN',
                              symbol: '₫',
                              decimalDigits: 0,
                            ).format(value),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                            ),
                          ),
                        );
                      },
                      reservedSize: 50,
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _calculateInterval(maxAbsValue),
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(positiveColor, 'Thu nhập'),
              const SizedBox(width: 16),
              _buildLegendItem(negativeColor, 'Chi tiêu'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  String _shortenName(String name) {
    if (name.length <= 8) return name;
    return '${name.substring(0, 6)}..';
  }

  double _calculateInterval(double maxValue) {
    if (maxValue <= 200000) return 50000;
    if (maxValue <= 500000) return 100000;
    if (maxValue <= 1000000) return 200000;
    return 500000;
  }
}