// blood_test_detail_screen.dart
import 'package:flutter/material.dart';
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

    final dataPoints = _getDataPoints(test);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Test Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 20),
                  const SizedBox(width: 8),
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

            const SizedBox(height: 18),

            Text(
              'All Values Summary',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Parameter',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Value',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Range',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Status',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Divider(),

                  ...dataPoints.map((point) {
                    final status = _getStatus(point);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: point.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    point.label,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Expanded(
                            flex: 3,
                            child: Text(
                              '${point.rawValue.toStringAsFixed(1)} ${point.unit}',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: point.color,
                              ),
                            ),
                          ),

                          Expanded(
                            flex: 2,
                            child: Text(
                              '${_formatRangeValue(point.minValue)}-${_formatRangeValue(point.maxValue)}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),

                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: status.color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  status.label,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: status.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
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

  ({String label, Color color}) _getStatus(ChartDataPoint point) {
    final value = point.rawValue;

    if (point.label == 'Calcium') {
      if (value >= 9 && value <= 10) {
        return (label: 'Good', color: Colors.green);
      }

      if ((value >= 8 && value < 9) || (value > 10 && value <= 11)) {
        return (label: 'Border', color: Colors.orange);
      }

      return (label: 'Alert', color: Colors.red);
    }

    final min = point.minValue;
    final max = point.maxValue;

    const double borderlineMargin = 5.0;

    final lowerAlertLimit = min - borderlineMargin;
    final lowerBorderlineLimit = min + borderlineMargin;

    final upperBorderlineLimit = max - borderlineMargin;
    final upperAlertLimit = max + borderlineMargin;

    if (value < lowerAlertLimit || value > upperAlertLimit) {
      return (label: 'Alert', color: Colors.red);
    }

    if ((value >= lowerAlertLimit && value <= lowerBorderlineLimit) ||
        (value >= upperBorderlineLimit && value <= upperAlertLimit)) {
      return (label: 'Border', color: Colors.orange);
    }

    return (label: 'Good', color: Colors.green);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatRangeValue(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(1);
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
      return 0.5 +
          ((rawValue - optimalValue) / (maxValue - optimalValue)) * 0.5;
    }
  }
}