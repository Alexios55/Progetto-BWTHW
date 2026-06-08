import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A reusable date input field that supports keyboard entry (DD/MM/YYYY)
/// with auto-formatting, plus a calendar icon to optionally pick a date
/// from a date picker. After picking from the calendar the field remains
/// editable via keyboard — the two modes coexist without a toggle.
///
/// Example usage:
/// ```dart
/// DateInputField(
///   controller: myController,
///   onDateParsed: (date) => setState(() => selectedDate = date),
/// )
/// ```
class DateInputField extends StatefulWidget {
  /// The controller for the underlying TextField.
  final TextEditingController controller;

  /// Label shown above the field.
  final String label;

  /// Hint text shown when the field is empty.
  final String hint;

  /// Earliest selectable date in the calendar picker. Defaults to 1900-01-01.
  final DateTime? firstDate;

  /// Latest selectable date in the calendar picker. Defaults to today.
  final DateTime? lastDate;

  /// Called whenever the field contains a fully valid date.
  /// Receives null if the field is cleared or the date becomes invalid.
  final ValueChanged<DateTime?>? onDateParsed;

  /// Optional prefix icon. Defaults to [Icons.calendar_today_outlined].
  final IconData? prefixIcon;

  const DateInputField({
    super.key,
    required this.controller,
    this.label = 'Date',
    this.hint = 'DD/MM/YYYY',
    this.firstDate,
    this.lastDate,
    this.onDateParsed,
    this.prefixIcon,
  });

  @override
  State<DateInputField> createState() => _DateInputFieldState();
}

class _DateInputFieldState extends State<DateInputField> {
  DateTime get _firstDate => widget.firstDate ?? DateTime(1900);
  DateTime get _lastDate => widget.lastDate ?? DateTime.now();

  // ── Keyboard path ──────────────────────────────────────────────────────────

  void _onChanged(String value) {
    final digits = value.replaceAll('/', '');
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length && i < 8; i++) {
      if (i == 2 || i == 4) buffer.write('/');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();

    if (widget.controller.text != formatted) {
      widget.controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    if (formatted.length == 10) {
      _notifyParsed(formatted);
    } else {
      widget.onDateParsed?.call(null);
    }
  }

  // ── Calendar path ──────────────────────────────────────────────────────────

  Future<void> _openCalendar() async {
    // Use whatever is already in the field as the calendar's starting point.
    DateTime initial = DateTime.now();
    if (widget.controller.text.length == 10) {
      try {
        final parts = widget.controller.text.split('/');
        final candidate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
        if (!candidate.isBefore(_firstDate) && !candidate.isAfter(_lastDate)) {
          initial = candidate;
        }
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: _firstDate,
      lastDate: _lastDate,
    );

    if (picked != null) {
      final formatted =
          '${picked.day.toString().padLeft(2, '0')}/'
          '${picked.month.toString().padLeft(2, '0')}/'
          '${picked.year}';

      widget.controller.text = formatted;
      widget.onDateParsed?.call(picked);
    }
  }

  // ── Parsing & validation ───────────────────────────────────────────────────

  void _notifyParsed(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length != 3) return;

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      if (month < 1 || month > 12 || day < 1 || day > 31) {
        widget.onDateParsed?.call(null);
        return;
      }

      final date = DateTime(year, month, day);

      if (date.isBefore(_firstDate) || date.isAfter(_lastDate)) {
        widget.onDateParsed?.call(null);
        return;
      }

      widget.onDateParsed?.call(date);
    } catch (_) {
      widget.onDateParsed?.call(null);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: widget.controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: _onChanged,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: Icon(widget.prefixIcon ?? Icons.calendar_today_outlined),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today, size: 20),
          tooltip: 'Pick from calendar',
          onPressed: _openCalendar,
        ),
      ),
    );
  }
}