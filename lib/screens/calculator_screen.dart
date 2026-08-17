import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/covant_header.dart';
import '../models/calculation_history.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // Input Utama
  final _tinggiController = TextEditingController();
  final _frekuensiController = TextEditingController();
  final _gainController = TextEditingController();

  // Input Parameter Tambahan (Default value)
  final _txPowerController = TextEditingController(text: '46');
  final _lossKabelController = TextEditingController(text: '2');
  final _targetRslController = TextEditingController(text: '-90');

  String _hasil = 'Hasil jangkauan akan muncul di sini.';
  double? _calculatedDistance;
  double? _calculatedMapl;

  double _log10(num x) => log(x) / ln10;

  void _hitungJangkauanUniversal() {
    // Konversi semua input menjadi angka desimal
    final ht = double.tryParse(_tinggiController.text);
    final f = double.tryParse(_frekuensiController.text);
    final gt = double.tryParse(_gainController.text);
    final pTx = double.tryParse(_txPowerController.text);
    final lMisc = double.tryParse(_lossKabelController.text);
    final rsl = double.tryParse(_targetRslController.text);

    // Validasi: Pastikan tidak ada yang kosong atau format salah
    if (ht == null || f == null || gt == null || pTx == null || lMisc == null || rsl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap isi semua parameter dengan angka yang valid!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // 1. Hitung MAPL (Maximum Allowable Path Loss)
      final mapl = pTx + gt - lMisc - rsl;

      double logD = 0.0;
      String modelName = "";

      // 2. Pemilihan Model Propagasi Universal
      if (f <= 1500.0) {
        modelName = "Okumura-Hata";
        final konstanta = 69.55 + (26.16 * _log10(f)) - (13.82 * _log10(ht));
        final pembagi = 44.9 - (6.55 * _log10(ht));
        logD = (mapl - konstanta) / pembagi;
      } else {
        modelName = "COST-231 Hata";
        const cm = 0.0; // Asumsi environment Urban
        final konstanta = 46.3 + (33.9 * _log10(f)) - (13.82 * _log10(ht)) + cm;
        final pembagi = 44.9 - (6.55 * _log10(ht));
        logD = (mapl - konstanta) / pembagi;
      }

      // 3. Konversi logaritma ke Jarak (Kilometer)
      final jarakKm = pow(10.0, logD).toDouble();

      // 4. Format Output
      final hasilFormat = jarakKm.toStringAsFixed(2);
      final maplFormat = mapl.toStringAsFixed(1);

      setState(() {
        _hasil =
            "Propagasi: $modelName (Urban)\nBatas Redaman (MAPL): $maplFormat dB\n\nEstimasi Jarak Jangkauan:\n$hasilFormat Kilometer";
        _calculatedDistance = jarakKm;
        _calculatedMapl = mapl;
      });

      // Simpan ke riwayat perhitungan
      CalculationHistory.addEntry(HistoryEntry(
        frequency: f.toInt(),
        gainAntenna: gt,
        heightAntenna: ht,
        envType: '$modelName (Urban)',
        distance: double.parse(hasilFormat),
        mapl: mapl.round(),
        date: DateTime.now(),
      ));
    }
  }

  @override
  void dispose() {
    _tinggiController.dispose();
    _frekuensiController.dispose();
    _gainController.dispose();
    _txPowerController.dispose();
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
          crossAxisAlignment: CrossAxisAlignment.center,
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
            const SizedBox(height: 12),

            // 2. Input Frekuensi
            _buildOutlinedTextField(
              controller: _frekuensiController,
              label: 'Frekuensi (MHz)',
            ),
            const SizedBox(height: 12),

            // 3. Input Gain Antena
            _buildOutlinedTextField(
              controller: _gainController,
              label: 'Gain Antena (dBi)',
            ),
            const SizedBox(height: 12),

            const Divider(height: 24, thickness: 1),
            const SizedBox(height: 12),

            // 4. Input Tx Power
            _buildOutlinedTextField(
              controller: _txPowerController,
              label: 'Tx Power Radio (dBm)',
            ),
            const SizedBox(height: 12),

            // 5. Input Loss Kabel
            _buildOutlinedTextField(
              controller: _lossKabelController,
              label: 'System/Cable Loss (dB)',
            ),
            const SizedBox(height: 12),

            // 6. Input Target RSL
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

            // Card untuk menampilkan hasil agar lebih rapi
            Card(
              elevation: 0,
              color: AppTheme.gray100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppTheme.gray200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    _hasil,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.gray800,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            if (_calculatedDistance != null) ...[
              const SizedBox(height: 24),
              _buildResultDiagram(_calculatedDistance!, _calculatedMapl ?? 0),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlinedTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildResultDiagram(double distance, double mapl) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 60,
                  child: CustomPaint(
                    size: const Size(60, 100),
                    painter: _TowerPainter(),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Container(height: 2, color: AppTheme.navy),
                      const SizedBox(height: 4),
                      Text(
                        '${distance.toStringAsFixed(2)} km',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.navy,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _building(12, 30),
                      const SizedBox(width: 3),
                      _building(14, 45),
                      const SizedBox(width: 3),
                      _building(10, 35),
                      const SizedBox(width: 3),
                      _building(16, 55),
                      const SizedBox(width: 3),
                      _building(12, 25),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _building(double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: const BoxDecoration(
        color: AppTheme.gray300,
        borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
      ),
    );
  }
}

class _TowerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.navy
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;

    canvas.drawLine(Offset(cx, 10), Offset(cx, size.height), paint);
    canvas.drawLine(Offset(cx - 10, 20), Offset(cx, 10), paint..strokeWidth = 1.5);
    canvas.drawLine(Offset(cx + 10, 20), Offset(cx, 10), paint);
    canvas.drawLine(Offset(cx - 15, size.height * 0.7), Offset(cx, size.height * 0.45), paint..strokeWidth = 2);
    canvas.drawLine(Offset(cx + 15, size.height * 0.7), Offset(cx, size.height * 0.45), paint);
    canvas.drawLine(Offset(cx - 20, size.height), Offset(cx, size.height * 0.65), paint);
    canvas.drawLine(Offset(cx + 20, size.height), Offset(cx, size.height * 0.65), paint);

    final dotPaint = Paint()
      ..color = AppTheme.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, 8), 4, dotPaint);

    final wavePaint = Paint()
      ..color = AppTheme.blue.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (int i = 1; i <= 3; i++) {
      final r = 8.0 + i * 8;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, 8), radius: r),
        -pi * 0.7,
        pi * 0.4,
        false,
        wavePaint..color = AppTheme.blue.withValues(alpha: 0.4 - i * 0.1),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

