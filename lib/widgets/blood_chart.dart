import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:bwthw_project/models/blood_test.dart';

class BloodChart extends StatelessWidget {
  final List<BloodTest> tests;
  final String parameter;

  const BloodChart({
    super.key,
    required this.tests,
    required this.parameter,
  });

  double getValue(BloodTest t) {
    switch (parameter) {
      case 'iron':
        return t.iron;
      case 'calcium':
        return t.calcium;
      case 'glucose':
        return t.glucose;
      case 'cholesterol':
        return t.cholesterol;
      case 'vitaminD':
        return t.vitaminD;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (tests.isEmpty) return const SizedBox();

    final spots = tests.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), getValue(e.value));
    }).toList();

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(show: false),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              spots: spots,
              dotData: FlDotData(show: true),
              barWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}