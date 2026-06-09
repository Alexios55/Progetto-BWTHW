import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bwthw_project/models.2/blood_test.dart';
import 'package:bwthw_project/utils/blood_analysis.dart';

class BloodTestDetailScreen extends StatefulWidget {
  final BloodTest test;

  const BloodTestDetailScreen({
    super.key,
    required this.test,
  });

  @override
  State<BloodTestDetailScreen> createState() => _BloodTestDetailScreenState();
}

class _BloodTestDetailScreenState extends State<BloodTestDetailScreen> {
  String selectedParameter = 'iron';

  double getValue(BloodTest t) {
    switch (selectedParameter) {
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

  Map<String, double> getRange() {
    switch (selectedParameter) {
      case 'iron':
        return {'min': 60, 'max': 170};
      case 'calcium':
        return {'min': 8.5, 'max': 10.5};
      case 'glucose':
        return {'min': 70, 'max': 100};
      case 'cholesterol':
        return {'min': 0, 'max': 200};
      case 'vitaminD':
        return {'min': 20, 'max': 50};
      default:
        return {'min': 0, 'max': 100};
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _chip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selectedParameter == value,
        onSelected: (_) {
          setState(() {
            selectedParameter = value;
          });
        },
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    final range = getRange();
    final value = getValue(widget.test);
    final colorScheme = Theme.of(context).colorScheme;

    double minY = range['min']! - 20;
    double maxY = range['max']! + 20;

    if (value < minY) {
      minY = value - 10;
    }
    if (value > maxY) {
      maxY = value + 10;
    }

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 1,
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: range['min']!,
                color: Colors.orange,
                strokeWidth: 2,
              ),
              HorizontalLine(
                y: range['max']!,
                color: Colors.red,
                strokeWidth: 2,
              ),
            ],
          ),
          lineBarsData: [
            LineChartBarData(
              isCurved: false,
              spots: [
                FlSpot(0, value),
                FlSpot(1, value),
              ],
              color: colorScheme.primary,
              barWidth: 3,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _valueBox(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Test Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Date: ${_formatDate(widget.test.date)}',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip('Iron', 'iron'),
                  _chip('Calcium', 'calcium'),
                  _chip('Glucose', 'glucose'),
                  _chip('Chol', 'cholesterol'),
                  _chip('Vit D', 'vitaminD'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildChart(context),
                    const SizedBox(height: 12),
                    Text(
                      'Normal range: ${getRange()['min']} - ${getRange()['max']}',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your value: ${getValue(widget.test).toStringAsFixed(1)}',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                BloodAnalysis.fullAnalysis(widget.test),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(child: _valueBox('Iron', '${widget.test.iron} µg/dL')),
                const SizedBox(width: 8),
                Expanded(child: _valueBox('Calcium', '${widget.test.calcium} mg/dL')),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _valueBox('Glucose', '${widget.test.glucose} mg/dL')),
                const SizedBox(width: 8),
                Expanded(child: _valueBox('Cholesterol', '${widget.test.cholesterol} mg/dL')),
              ],
            ),
            const SizedBox(height: 8),
            _valueBox('Vitamin D', '${widget.test.vitaminD} ng/mL'),
          ],
        ),
      ),
    );
  }
}