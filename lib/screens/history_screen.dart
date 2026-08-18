import 'dart:math';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
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
    return GestureDetector(
      onTap: () => _showDetailDialog(entry),
      child: Container(
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
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.touch_app_rounded, size: 14, color: AppTheme.gray400),
                const SizedBox(width: 4),
                Text(
                  'Tap untuk detail',
                  style: TextStyle(fontSize: 10.5, color: AppTheme.gray400),
                ),
              ],
            ),
          ],
        ),
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

  // ====================================================================
  //  DETAIL POPUP DIALOG
  // ====================================================================
  void _showDetailDialog(HistoryEntry entry) {
    showDialog(
      context: context,
      builder: (ctx) => _HistoryDetailDialog(entry: entry),
    );
  }
}

// ======================================================================
//  _CalcStep — shared step representation
// ======================================================================
class _CalcStep {
  final String label;
  final String expr;
  final String value;
  const _CalcStep(this.label, this.expr, this.value);
}

// ======================================================================
//  DETAIL DIALOG — Stateful to manage video controller lifecycle
// ======================================================================
class _HistoryDetailDialog extends StatefulWidget {
  final HistoryEntry entry;
  const _HistoryDetailDialog({required this.entry});

  @override
  State<_HistoryDetailDialog> createState() => _HistoryDetailDialogState();
}

class _HistoryDetailDialogState extends State<_HistoryDetailDialog> {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;
  List<_CalcStep> _steps = [];

  double _log10(num x) => log(x) / ln10;
  double _wattToDbm(double watt) => 30 + _log10(watt);

  @override
  void initState() {
    super.initState();
    _recalculateSteps();
    _initVideo();
  }

  void _recalculateSteps() {
    final e = widget.entry;

    // If we don't have ptxWatt stored (old entries), show basic info only
    if (e.ptxWatt == null || e.lossKabel == null || e.targetRsl == null) {
      _steps = [
        _CalcStep('Frekuensi', '—', '${e.frequency} MHz'),
        _CalcStep('Gain Antena', '—', '${e.gainAntenna} dBi'),
        _CalcStep('Tinggi Antena', '—', '${e.heightAntenna} m'),
        _CalcStep('MAPL', '—', '${e.mapl} dB'),
        _CalcStep('Jangkauan', '—', '${e.distance} km'),
      ];
      return;
    }

    final freq = e.frequency;
    final ht = e.heightAntenna;
    final gt = e.gainAntenna;
    final ptxWatt = e.ptxWatt!;
    final lMisc = e.lossKabel!;
    final rsl = e.targetRsl!;
    final cm = e.cm ?? 0;

    final ptxDbm = _wattToDbm(ptxWatt);
    final mapl = ptxDbm + gt - lMisc - rsl;

    String modelName;
    double konstanta;
    String konstantaExpr;
    if (freq <= 1500) {
      modelName = 'Okumura-Hata';
      konstanta = 69.55 + (26.16 * _log10(freq)) - (13.82 * _log10(ht));
      konstantaExpr = '69.55 + 26.16·log(f) − 13.82·log(ht)';
    } else {
      modelName = 'COST-231 Hata';
      konstanta = 46.3 + (33.9 * _log10(freq)) - (13.82 * _log10(ht)) + cm;
      konstantaExpr =
          '46.3 + 33.9·log(f) − 13.82·log(ht) + Cm(${cm.toStringAsFixed(0)})';
    }

    final pembagi = 44.9 - (6.55 * _log10(ht));
    final logD = (mapl - konstanta) / pembagi;

    _steps = [
      _CalcStep('Konversi Daya Pancar', '30 + log(Ptx watt)',
          '${ptxDbm.toStringAsFixed(2)} dBm'),
      _CalcStep('MAPL', 'Ptx(dBm) + Gt − Lmisc − RSL',
          '${mapl.toStringAsFixed(2)} dB'),
      _CalcStep('Model dipakai', 'f = $freq MHz', modelName),
      _CalcStep('Konstanta model', konstantaExpr, konstanta.toStringAsFixed(2)),
      _CalcStep(
          'Faktor pembagi', '44.9 − 6.55·log(ht)', pembagi.toStringAsFixed(2)),
      _CalcStep('log10(d)', '(MAPL − Konstanta) / Pembagi',
          logD.toStringAsFixed(3)),
    ];
  }

  void _initVideo() {
    final List<String> paths = [
      'lib/asset/vidio/ANIMASI_TOWER.mp4',
      'assets/videos/animasi_tower.mp4',
    ];

    void tryLoadPath(int index) {
      if (index >= paths.length) {
        debugPrint('Failed to load video from all candidate paths.');
        return;
      }
      final path = paths[index];
      _videoController = VideoPlayerController.asset(path)
        ..initialize()
            .then((_) {
              if (mounted) {
                _videoController.setLooping(true);
                _videoController.setVolume(0.0);
                _videoController.play();
                setState(() => _isVideoInitialized = true);
              }
            })
            .catchError((error) {
              debugPrint('Error loading video from $path: $error');
              tryLoadPath(index + 1);
            });
    }

    tryLoadPath(0);
  }

  @override
  void dispose() {
    if (_isVideoInitialized) {
      _videoController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    final dateStr =
        '${e.date.day}/${e.date.month}/${e.date.year}  ${e.date.hour}:${e.date.minute.toString().padLeft(2, '0')}';

    // Determine model name for result card
    String modelName;
    if (e.frequency <= 1500) {
      modelName = 'Okumura-Hata';
    } else {
      modelName = 'COST-231 Hata';
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: AppTheme.bg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              decoration: BoxDecoration(
                color: AppTheme.navy,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${e.frequency} MHz',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable content ──
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Input Parameters ──
                    _buildSectionTitle('Parameter Input'),
                    const SizedBox(height: 8),
                    _buildParamGrid(e),
                    const SizedBox(height: 20),

                    // ── Proses Hitung ──
                    _buildSectionTitle('Proses Hitung'),
                    const SizedBox(height: 8),
                    _buildProsesHitung(),
                    const SizedBox(height: 20),

                    // ── Final Result Card ──
                    _buildFinalResultCard(e.distance.toDouble(), e.mapl.toDouble(), modelName),
                    const SizedBox(height: 20),

                    // ── Video & Estimation ──
                    _buildVideoSection(e.distance.toDouble()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppTheme.blue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.gray800,
          ),
        ),
      ],
    );
  }

  Widget _buildParamGrid(HistoryEntry e) {
    final params = <_ParamItem>[
      _ParamItem('Frekuensi', '${e.frequency} MHz'),
      _ParamItem('Tinggi Antena', '${e.heightAntenna} m'),
      _ParamItem('Gain Antena', '${e.gainAntenna} dBi'),
      if (e.ptxWatt != null)
        _ParamItem('Daya Pancar', '${e.ptxWatt} W'),
      if (e.lossKabel != null)
        _ParamItem('Loss Kabel', '${e.lossKabel} dB'),
      if (e.targetRsl != null)
        _ParamItem('Target RSL', '${e.targetRsl} dBm'),
      _ParamItem('Model', e.envType),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gray200),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: params.map((p) => _buildParamChip(p)).toList(),
      ),
    );
  }

  Widget _buildParamChip(_ParamItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.gray50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.label,
            style: const TextStyle(fontSize: 9.5, color: AppTheme.gray400, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            item.value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.gray800),
          ),
        ],
      ),
    );
  }

  Widget _buildProsesHitung() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.gray100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gray200),
      ),
      child: Column(
        children: _steps.asMap().entries.map((mapEntry) {
          final index = mapEntry.key;
          final step = mapEntry.value;
          return Column(
            children: [
              if (index > 0)
                Divider(height: 1, color: AppTheme.gray200),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppTheme.blueLight,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.navy,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(step.label,
                              style: const TextStyle(
                                  fontSize: 12, color: AppTheme.gray600)),
                          const SizedBox(height: 1),
                          Text(step.expr,
                              style: const TextStyle(
                                  fontSize: 10, color: AppTheme.gray400)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        step.value,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.gray800,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFinalResultCard(double distance, double mapl, String modelName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.navy,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '● $modelName',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Panjang Jangkauan / Daya Pancar',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            '${distance.toStringAsFixed(2)} km',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'MAPL: ${mapl.toStringAsFixed(2)} dB',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection(double distance) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_isVideoInitialized)
            SizedBox(
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio > 0
                      ? _videoController.value.aspectRatio
                      : 16 / 9,
                  child: VideoPlayer(_videoController),
                ),
              ),
            )
          else
            Container(
              height: 120,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.cell_tower, size: 40, color: AppTheme.navy),
                  SizedBox(height: 8),
                  Text(
                    'Memuat Animasi Coverage...',
                    style: TextStyle(fontSize: 12, color: AppTheme.gray500),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.blueLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Estimasi Jangkauan: ${distance.toStringAsFixed(2)} km',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParamItem {
  final String label;
  final String value;
  const _ParamItem(this.label, this.value);
}
