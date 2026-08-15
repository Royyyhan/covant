import 'package:flutter/foundation.dart';

class HistoryEntry {
  final int frequency;
  final double gainAntenna;
  final double heightAntenna;
  final String envType;
  final double distance;
  final int mapl;
  final DateTime date;

  HistoryEntry({
    required this.frequency,
    required this.gainAntenna,
    required this.heightAntenna,
    required this.envType,
    required this.distance,
    required this.mapl,
    required this.date,
  });
}

class CalculationHistory {
  static final List<HistoryEntry> _entries = [];
  static final ValueNotifier<int> notifier = ValueNotifier(0);

  static List<HistoryEntry> get entries => List.unmodifiable(_entries);

  static void addEntry(HistoryEntry entry) {
    _entries.insert(0, entry);
    if (_entries.length > 20) _entries.removeLast();
    notifier.value++;
  }
}
