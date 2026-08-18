import 'dart:math';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../theme/app_theme.dart';
import '../widgets/covant_header.dart';
import '../models/calculation_history.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalcStep {
  final String label;
  final String expr;
  final String value;
  const _CalcStep(this.label, this.expr, this.value);
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // Input Utama
  final _tinggiController = TextEditingController();
  final _gainController = TextEditingController();

  // Daya pancar sekarang dalam WATT, dikonversi ke dBm
  final _ptxWattController = TextEditingController();
  double? _ptxDbmPreview;

  // Input Parameter Tambahan
  final _lossKabelController = TextEditingController(text: '2');
  final _targetRslController = TextEditingController(text: '-90');

  // Frequency Selection (pengganti input teks bebas)
  int? _selectedFreq; // 900 atau 1800

  // Faktor koreksi Cm — cuma relevan kalau freq = 1800 MHz (COST-231 Hata)
  double _cm = 0;

  List<_CalcStep> _steps = [];
  double? _calculatedDistance;
  double? _calculatedMapl;
  String? _modelName;

  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
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
                _videoController.addListener(() {
                  if (mounted && _videoController.value.isInitialized) {
                    if (!_videoController.value.isPlaying &&
                        _videoController.value.position >=
                            _videoController.value.duration) {
                      _videoController.seekTo(Duration.zero);
                      _videoController.play();
                    }
                  }
                });
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

  double _log10(num x) => log(x) / ln10;

  /// Konversi daya pancar dari Watt ke dBm: dBm = 30 + log10(Watt)
  double _wattToDbm(double watt) => 30 + _log10(watt);

  void _onPtxWattChanged(String value) {
    final w = double.tryParse(value);
    setState(() {
      _ptxDbmPreview = (w != null && w > 0) ? _wattToDbm(w) : null;
    });
  }

  Future<void> _hitungJangkauanUniversal() async {
    final ht = double.tryParse(_tinggiController.text);
    final gt = double.tryParse(_gainController.text);
    final ptxWatt = double.tryParse(_ptxWattController.text);
    final lMisc = double.tryParse(_lossKabelController.text);
    final rsl = double.tryParse(_targetRslController.text);
    final freq = _selectedFreq;

    if (freq == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih frekuensi dulu (900 MHz atau 1800 MHz).'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (ht == null ||
        gt == null ||
        ptxWatt == null ||
        ptxWatt <= 0 ||
        lMisc == null ||
        rsl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap isi semua parameter dengan angka yang valid!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 1. Konversi Ptx Watt -> dBm
    final ptxDbm = _wattToDbm(ptxWatt);

    // 2. Hitung MAPL (Maximum Allowable Path Loss)
    final mapl = ptxDbm + gt - lMisc - rsl;

    // 3. Pemilihan model + konstanta sesuai frekuensi
    String modelName;
    double konstanta;
    String konstantaExpr;
    if (freq <= 1500) {
      modelName = 'Okumura-Hata';
      konstanta = 69.55 + (26.16 * _log10(freq)) - (13.82 * _log10(ht));
      konstantaExpr = '69.55 + 26.16·log(f) − 13.82·log(ht)';
    } else {
      modelName = 'COST-231 Hata';
      konstanta =
          46.3 + (33.9 * _log10(freq)) - (13.82 * _log10(ht)) + _cm;
      konstantaExpr =
          '46.3 + 33.9·log(f) − 13.82·log(ht) + Cm(${_cm.toStringAsFixed(0)})';
    }

    final pembagi = 44.9 - (6.55 * _log10(ht));
    final logD = (mapl - konstanta) / pembagi;
    final jarakKm = pow(10.0, logD).toDouble();

    final steps = <_CalcStep>[
      _CalcStep('Konversi Daya Pancar', '30 + log(Ptx watt)',
          '${ptxDbm.toStringAsFixed(2)} dBm'),
      _CalcStep('MAPL', 'Ptx(dBm) + Gt − Lmisc − RSL',
          '${mapl.toStringAsFixed(2)} dB'),
      _CalcStep('Model dipakai', 'f = $freq MHz', modelName),
      _CalcStep('Konstanta model', konstantaExpr, konstanta.toStringAsFixed(2)),
      _CalcStep('Faktor pembagi', '44.9 − 6.55·log(ht)', pembagi.toStringAsFixed(2)),
      _CalcStep('log10(d)', '(MAPL − Konstanta) / Pembagi', logD.toStringAsFixed(3)),
    ];

    setState(() {
      _steps = steps;
      _calculatedDistance = jarakKm;
      _calculatedMapl = mapl;
      _modelName = modelName;
    });

    await CalculationHistory.addEntry(
      HistoryEntry(
        frequency: freq,
        gainAntenna: gt,
        heightAntenna: ht,
        envType: freq > 1500
            ? '$modelName (Cm=${_cm.toStringAsFixed(0)} dB)'
            : modelName,
        distance: double.parse(jarakKm.toStringAsFixed(2)),
        mapl: mapl.round(),
        date: DateTime.now(),
        ptxWatt: ptxWatt,
        lossKabel: lMisc,
        targetRsl: rsl,
        cm: _cm,
      ),
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    _tinggiController.dispose();
    _gainController.dispose();
    _ptxWattController.dispose();
    _lossKabelController.dispose();
    _targetRslController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CovantHeader(),
            const SizedBox(height: 8),

            const Text(
              'RF Coverage Calculator',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.gray800,
              ),
            ),
            const SizedBox(height: 24),

            // 1. Input Tinggi Antena
            _buildOutlinedTextField(
              controller: _tinggiController,
              label: 'Tinggi Antena (Meter)',
            ),
            const SizedBox(height: 16),

            // 2. Frequency Selection (pilih 900 / 1800 MHz)
            _buildFrequencySelector(),

            // 3. Faktor Koreksi Cm — cuma tampil kalau 1800 MHz
            if (_selectedFreq != null && _selectedFreq! > 1500) ...[
              const SizedBox(height: 16),
              _buildCmSelector(),
            ],
            const SizedBox(height: 16),

            // 4. Input Gain Antena
            _buildOutlinedTextField(
              controller: _gainController,
              label: 'Gain Antena (dBi)',
            ),
            const SizedBox(height: 12),

            const Divider(height: 24, thickness: 1),
            const SizedBox(height: 12),

            // 5. Input Ptx dalam WATT (dikonversi otomatis ke dBm)
            _buildOutlinedTextField(
              controller: _ptxWattController,
              label: 'Daya Pancar Tx (Watt)',
              onChanged: _onPtxWattChanged,
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.blueLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _ptxDbmPreview != null
                      ? '= ${_ptxDbmPreview!.toStringAsFixed(2)} dBm'
                      : '= — dBm',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.navy,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 6. Input Loss Kabel
            _buildOutlinedTextField(
              controller: _lossKabelController,
              label: 'System/Cable Loss - Lmisc (dB)',
            ),
            const SizedBox(height: 12),

            // 7. Input Target RSL
            _buildOutlinedTextField(
              controller: _targetRslController,
              label: 'Target RSL / Rx Level (dBm)',
            ),
            const SizedBox(height: 24),

            // Tombol Hitung
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _hitungJangkauanUniversal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.navy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Hitung Jangkauan Universal'),
              ),
            ),
            const SizedBox(height: 24),

            // Proses hitung — tiap langkah ditampilkan satu-satu
            if (_steps.isNotEmpty) _buildProsesHitung(),

            if (_calculatedDistance != null) ...[
              const SizedBox(height: 20),
              _buildFinalResultCard(_calculatedDistance!, _calculatedMapl ?? 0),
              const SizedBox(height: 24),
              _buildResultDiagram(_calculatedDistance!, _calculatedMapl ?? 0),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ---------- Frequency Selection (900 / 1800 MHz) ----------
  Widget _buildFrequencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Frequency Selection',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.gray800,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppTheme.gray200,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(child: _freqSegment(900, 'Okumura-Hata')),
              const SizedBox(width: 4),
              Expanded(child: _freqSegment(1800, 'COST-231 Hata')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _freqSegment(int freq, String modelHint) {
    final selected = _selectedFreq == freq;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFreq = freq;
          if (freq <= 1500) _cm = 0; // Cm nggak dipakai untuk Okumura-Hata
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppTheme.navy : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          '$freq MHz',
          style: TextStyle(
            color: selected ? Colors.white : AppTheme.gray600,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  // ---------- Faktor Koreksi Cm (0 dB / 3 dB) ----------
  Widget _buildCmSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Faktor Koreksi (Cm)',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.gray800,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppTheme.gray200,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(child: _cmSegment(0)),
              const SizedBox(width: 4),
              Expanded(child: _cmSegment(3)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _cm == 3
              ? 'Cm = 3 dB — kota besar / pusat metropolitan (gedung tinggi & padat).'
              : 'Cm = 0 dB — kota sedang / area pinggiran (suburban).',
          style: const TextStyle(fontSize: 11.5, color: AppTheme.gray500),
        ),
      ],
    );
  }

  Widget _cmSegment(double cmValue) {
    final selected = _cm == cmValue;
    return GestureDetector(
      onTap: () => setState(() => _cm = cmValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.navy : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          '${cmValue.toStringAsFixed(0)} dB',
          style: TextStyle(
            color: selected ? Colors.white : AppTheme.gray600,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // ---------- Proses Hitung (tiap langkah ditampilkan) ----------
  Widget _buildProsesHitung() {
    return Card(
      elevation: 0,
      color: AppTheme.gray100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.gray200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              const Text(
                'Proses Hitung',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.gray800,
                ),
              ),
              const SizedBox(height: 8),
              for (final step in _steps) _buildStepRow(step),
            ],
          ),
        ),
      );
    }

    Widget _buildStepRow(_CalcStep step) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.label,
                    style: const TextStyle(
                        fontSize: 12.5, color: AppTheme.gray600)),
                const SizedBox(height: 2),
                Text(step.expr,
                    style: const TextStyle(
                        fontSize: 10.5, color: AppTheme.gray400)),
              ],
            ),
          ),
          Text(
            step.value,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.gray800,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Hasil Akhir: Panjang Jangkauan / Daya Pancar ----------
  Widget _buildFinalResultCard(double distance, double mapl) {
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
            '● ${_modelName ?? ''}',
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
              fontSize: 32,
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

  Widget _buildOutlinedTextField({
    required TextEditingController controller,
    required String label,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.gray600, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.gray300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.gray300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.navy, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildResultDiagram(double distance, double mapl) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            Container(
              constraints: const BoxConstraints(maxHeight: 250, maxWidth: 350),
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
              height: 140,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cell_tower, size: 48, color: AppTheme.navy),
                  const SizedBox(height: 8),
                  const Text(
                    'Memuat Animasi Coverage...',
                    style: TextStyle(fontSize: 12, color: AppTheme.gray500),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
