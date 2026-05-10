import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bwthw_project/models.2/blood_test.dart';
import 'package:bwthw_project/services/preference_service.dart';
import 'package:bwthw_project/utils/blood_analysis.dart';

class BloodTestScreen extends StatefulWidget {
  const BloodTestScreen({super.key});

  @override
  State<BloodTestScreen> createState() => _BloodTestScreenState();
}

class _BloodTestScreenState extends State<BloodTestScreen> {
  List<BloodTest> tests = [];
  String selectedParameter = 'iron';

  @override
  void initState() {
    super.initState();
    loadTests();
  }

  Future<void> loadTests() async {
    final loaded = await PreferenceService.getBloodTests();
    setState(() => tests = loaded);
  }

  // Taking the value of the selected parameter from the blood test
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

  // Normal range for each parameter
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Blood Tests')),
      body: tests.isEmpty
          ? const Center(child: Text('No data'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Parameter selection chips
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

                  // Chart with colored range
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildChart(),

                          const SizedBox(height: 12),

                          // RANGE LABEL
                          Text(
                            'Normal range: ${getRange()['min']} - ${getRange()['max']}',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Analysis of the latest test
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      BloodAnalysis.fullAnalysis(tests.last),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // List of all tests in a card format
                  Column(
                    children: tests
                        .map((t) => _historyCard(context, t))
                        .toList(),
                  ),
                ],
              ),
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result =
              await Navigator.pushNamed(context, '/add-blood-test');

          if (result != null) {
            tests.add(result as BloodTest);
            tests.sort((a, b) => b.date.compareTo(a.date));

            await PreferenceService.saveBloodTests(tests);

            setState(() {});
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // chips for selecting the parameter to display in the chart
  Widget _chip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selectedParameter == value,
        onSelected: (_) {
          setState(() => selectedParameter = value);
        },
      ),
    );
  }

  // Chart with colored range for the selected parameter
  Widget _buildChart() {
    final range = getRange();

    final spots = tests.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), getValue(e.value));
    }).toList();

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: range['min']! - 20,
          maxY: range['max']! + 20,

          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),

          // 🎨 RANGE COLORATO
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
              isCurved: true,
              spots: spots,
              barWidth: 3,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  // Card for each blood test in the history list
  Widget _historyCard(BuildContext context, BloodTest t) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(t.date.toString().split(' ')[0]),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(child: _box('Iron', '${t.iron} µg/dL')),
                  const SizedBox(width: 8),
                  Expanded(child: _box('Calcium', '${t.calcium} mg/dL')),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _box('Glucose', '${t.glucose} mg/dL')),
                  const SizedBox(width: 8),
                  Expanded(child: _box('Chol', '${t.cholesterol} mg/dL')),
                ],
              ),
              const SizedBox(height: 8),
              _box('Vitamin D', '${t.vitaminD} ng/mL'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _box(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
