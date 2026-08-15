import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/covant_header.dart';
import '../models/calculation_history.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final Map<String, String> _envLabels = {
    'urban-small': 'Urban (S/M)',
    'urban-large': 'Urban (Large)',
    'suburban': 'Suburban',
    'open': 'Open Area',
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: CalculationHistory.notifier,
        builder: (context, _) {
          final entries = CalculationHistory.entries;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CovantHeader(),
                const SizedBox(height: 8),
                const Text(
                  'Riwayat Perhitungan',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.gray800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Lihat riwayat hasil perhitungan path loss Anda.',
                  style: TextStyle(fontSize: 13, color: AppTheme.gray500),
                ),
                const SizedBox(height: 24),
                if (entries.isEmpty) _buildEmpty() else _buildList(entries),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(Icons.history, size: 48, color: AppTheme.gray300),
            const SizedBox(height: 12),
            const Text(
              'Belum ada riwayat perhitungan.',
              style: TextStyle(fontSize: 14, color: AppTheme.gray400),
            ),
            const SizedBox(height: 4),
            const Text(
              'Mulai hitung di tab Calculator untuk melihat riwayat di sini.',
              style: TextStyle(fontSize: 12, color: AppTheme.gray400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<HistoryEntry> entries) {
    return Column(
      children: entries.map((e) => _buildHistoryItem(e)).toList(),
    );
  }

  Widget _buildHistoryItem(HistoryEntry entry) {
    final dateStr =
        '${entry.date.day}/${entry.date.month}/${entry.date.year} ${entry.date.hour}:${entry.date.minute.toString().padLeft(2, '0')}';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gray100),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.navy,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${entry.frequency} MHz',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
              Text(dateStr, style: const TextStyle(fontSize: 11, color: AppTheme.gray400)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: [
              _detail('MAPL:', '${entry.mapl} dB'),
              _detail('Dist:', '${entry.distance} km'),
              Text(
                _envLabels[entry.envType] ?? entry.envType,
                style: const TextStyle(fontSize: 12, color: AppTheme.gray600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detail(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 12, fontFamily: 'Inter', color: AppTheme.gray600),
        children: [
          TextSpan(text: label),
          const TextSpan(text: ' '),
          TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.navy)),
        ],
      ),
    );
  }
}
