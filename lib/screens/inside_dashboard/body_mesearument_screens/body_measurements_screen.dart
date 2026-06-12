import 'package:flutter/material.dart';
import 'package:bwthw_project/models.2/input_mesearument_models/body_measurement_entry.dart';
import 'package:bwthw_project/services/preference_service.dart';

class BodyMeasurementsScreen extends StatefulWidget {
  const BodyMeasurementsScreen({super.key});

  @override
  State<BodyMeasurementsScreen> createState() => _BodyMeasurementsScreenState();
}

class _BodyMeasurementsScreenState extends State<BodyMeasurementsScreen> {
  List<BodyMeasurementEntry> entries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final loaded = await PreferenceService.getBodyMeasurementEntries();
    loaded.sort((a, b) => b.date.compareTo(a.date));

    setState(() {
      entries = loaded;
    });
  }

  Future<void> _addEntry() async {
    final result = await Navigator.pushNamed(context, '/add-body-measurement');

    if (result != null) {
      entries.add(result as BodyMeasurementEntry);
      entries.sort((a, b) => b.date.compareTo(a.date));

      await PreferenceService.saveBodyMeasurementEntries(entries);

      setState(() {});
    }
  }

  Future<void> _deleteEntry(int index) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete measurement'),
          content: const Text(
            'Do you want to remove this saved measurement?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    entries.removeAt(index);
    await PreferenceService.saveBodyMeasurementEntries(entries);

    setState(() {});
  }

  void _showHowToMeasureDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'How to take measurements',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Image.asset(
                  'assets/images/body_measurements_guide.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Add the guide image in assets/images/body_measurements_guide.png',
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const _GuideText(
                  number: '1',
                  title: 'CHEST',
                  description:
                      'Measure the chest at its widest point, touching the shoulder blades and nipples.',
                ),
                const _GuideText(
                  number: '2',
                  title: 'ARM',
                  description:
                      'Measure the upper arm circumference, that is, the biceps, which is the largest part.',
                ),
                const _GuideText(
                  number: '3',
                  title: 'WAIST',
                  description:
                      'Measure the narrowest part of the waist, usually located between 2.5 cm and 5 cm above the navel.',
                ),
                const _GuideText(
                  number: '4',
                  title: 'HIPS',
                  description:
                      'Measure the widest part, which is generally found slightly above the crotch.',
                ),
                const _GuideText(
                  number: '5',
                  title: 'THIGH',
                  description:
                      'Measure the upper part of the thigh at its widest point, about 3/4 of the way up from the knee.',
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }

  Widget _buildAddTile(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: _addEntry,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.primary),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.add, color: colorScheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Add Measurement',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryCard(
    BuildContext context,
    BodyMeasurementEntry entry,
    int index,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Measurement - ${_formatDate(entry.date)}',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _deleteEntry(index),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _valueRow('Chest', '${_formatNumber(entry.chest)} cm'),
          const SizedBox(height: 8),
          _valueRow('Arm', '${_formatNumber(entry.arm)} cm'),
          const SizedBox(height: 8),
          _valueRow('Waist', '${_formatNumber(entry.waist)} cm'),
          const SizedBox(height: 8),
          _valueRow('Hips', '${_formatNumber(entry.hips)} cm'),
          const SizedBox(height: 8),
          _valueRow('Thigh', '${_formatNumber(entry.thigh)} cm'),
        ],
      ),
    );
  }

  Widget _valueRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
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
        title: const Text('Body Measurements'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showHowToMeasureDialog,
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saved Measurements',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Save your body measurements and track them over time.',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _showHowToMeasureDialog,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.accessibility_new,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'How to measure your body',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (entries.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.straighten,
                      size: 46,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No measurements yet',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your saved measurements will appear here.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              ...entries.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildEntryCard(context, entry.value, entry.key),
                );
              }),
            ],
            _buildAddTile(context),
          ],
        ),
      ),
    );
  }
}

class _GuideText extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const _GuideText({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            child: Text(number),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}