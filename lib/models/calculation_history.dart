import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// Convert to JSON map for persistence
  Map<String, dynamic> toJson() => {
        'frequency': frequency,
        'gainAntenna': gainAntenna,
        'heightAntenna': heightAntenna,
        'envType': envType,
        'distance': distance,
        'mapl': mapl,
        'date': date.toIso8601String(),
      };

  /// Create from JSON map
  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
        frequency: json['frequency'] as int,
        gainAntenna: (json['gainAntenna'] as num).toDouble(),
        heightAntenna: (json['heightAntenna'] as num).toDouble(),
        envType: json['envType'] as String,
        distance: (json['distance'] as num).toDouble(),
        mapl: json['mapl'] as int,
        date: DateTime.parse(json['date'] as String),
      );
}

class CalculationHistory {
  static const String _storageKey = 'calculation_history';
  static final List<HistoryEntry> _entries = [];
  static final ValueNotifier<int> notifier = ValueNotifier(0);

  static List<HistoryEntry> get entries => List.unmodifiable(_entries);

  /// Initialize history from SharedPreferences cache.
  /// Call this once at app startup (before runApp or in main).
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
        _entries.clear();
        _entries.addAll(
          decoded.map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>)),
        );
        notifier.value++;
      } catch (e) {
        debugPrint('Failed to load history from cache: $e');
      }
    }
  }

  /// Add a new entry and persist to SharedPreferences
  static Future<void> addEntry(HistoryEntry entry) async {
    _entries.insert(0, entry);
    if (_entries.length > 20) _entries.removeLast();
    notifier.value++;
    await _save();
  }

  /// Clear all history entries and persist
  static Future<void> clearAll() async {
    _entries.clear();
    notifier.value++;
    await _save();
  }

  /// Persist current entries to SharedPreferences
  static Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }
}
