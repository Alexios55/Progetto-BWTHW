// blood_test_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bwthw_project/models.2/input_mesearument_models/blood_test.dart';

class BloodTestDetailScreen extends StatelessWidget {
  final BloodTest test;

  const BloodTestDetailScreen({
    super.key,
    required this.test,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Prepara i dati per il grafico
    final dataPoints = _getDataPoints(test);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Test Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card con data
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
                      'Date: ${_formatDate(test.date)}',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            
            const SizedBox(height: 20),

            // Tabella riassuntiva con tutti i valori
            Text(
              'All Values Summary',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                children: [
                  // Header
                  Row(
                    children: [
                      const Expanded(
                        flex: 2,
                        child: Text(
                          'Parameter',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Expanded(
                        flex: 2,
                        child: Text(
                          'Value',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Expanded(
                        flex: 1,
                        child: Text(
                          'Range',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Expanded(
                        flex: 1,
                        child: Text(
                          'Status',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  ...dataPoints.map((point) {
                    final status = _getStatus(point.normalizedValue);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: point.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  point.label,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${point.rawValue.toStringAsFixed(1)} ${point.unit}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: point.color,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              '${point.minValue} - ${point.maxValue}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: status.color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                status.label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: status.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ChartDataPoint> _getDataPoints(BloodTest test) {
    return [
      ChartDataPoint(
        label: 'Iron',
        shortLabel: 'Fe',
        rawValue: test.iron,
        unit: 'µg/dL',
        minValue: 60,
        optimalValue: 110,
        maxValue: 170,
        color: Colors.blue,
      ),
      ChartDataPoint(
        label: 'Calcium',
        shortLabel: 'Ca',
        rawValue: test.calcium,
        unit: 'mg/dL',
        minValue: 8.5,
        optimalValue: 9.5,
        maxValue: 10.5,
        color: Colors.green,
      ),
      ChartDataPoint(
        label: 'Glucose',
        shortLabel: 'Glu',
        rawValue: test.glucose,
        unit: 'mg/dL',
        minValue: 70,
        optimalValue: 90,
        maxValue: 100,
        color: Colors.orange,
      ),
      ChartDataPoint(
        label: 'Cholesterol',
        shortLabel: 'Chol',
        rawValue: test.cholesterol,
        unit: 'mg/dL',
        minValue: 0,
        optimalValue: 100,
        maxValue: 200,
        color: Colors.purple,
      ),
      ChartDataPoint(
        label: 'Vitamin D',
        shortLabel: 'VitD',
        rawValue: test.vitaminD,
        unit: 'ng/mL',
        minValue: 20,
        optimalValue: 40,
        maxValue: 80,
        color: Colors.teal,
      ),
    ];
  }

  ({String label, Color color}) _getStatus(double normalizedValue) {
    if (normalizedValue >= 0.3 && normalizedValue <= 0.7) {
      return (label: '✅ Good', color: Colors.green);
    } else if (normalizedValue >= 0.2 && normalizedValue <= 0.8) {
      return (label: '⚠️ Borderline', color: Colors.orange);
    } else {
      return (label: '❌ Alert', color: Colors.red);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class ChartDataPoint {
  final String label;
  final String shortLabel;
  final double rawValue;
  final String unit;
  final double minValue;
  final double optimalValue;
  final double maxValue;
  final Color color;

  ChartDataPoint({
    required this.label,
    required this.shortLabel,
    required this.rawValue,
    required this.unit,
    required this.minValue,
    required this.optimalValue,
    required this.maxValue,
    required this.color,
  });

  double get normalizedValue {
    if (rawValue < minValue) {
      return 0;
    } else if (rawValue > maxValue) {
      return 1;
    } else if (rawValue <= optimalValue) {
      return ((rawValue - minValue) / (optimalValue - minValue)) * 0.5;
    } else {
      return 0.5 + ((rawValue - optimalValue) / (maxValue - optimalValue)) * 0.5;
    }
  }
}