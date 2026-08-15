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
  int _selectedFreq = 900;
  final _gainController = TextEditingController(text: '30');
  final _heightController = TextEditingController(text: '1.5');
  final _distanceController = TextEditingController(text: '5');
  String _envType = 'urban-small';
  double _maplValue = 147;
  double _distanceDisplay = 4.5;

  final Map<String, String> _envLabels = {
    'urban-small': 'Urban (Small/Medium City)',
    'urban-large': 'Urban (Large City)',
    'suburban': 'Suburban',
    'open': 'Open Area',
  };

  void _computePathLoss() {
    final freq = _selectedFreq.toDouble();
    final hm = double.tryParse(_heightController.text) ?? 1.5;
    final distance = double.tryParse(_distanceController.text) ?? 5;

    // Correction factor a(hm)
    double ahm;
    if (_envType == 'urban-large' && freq >= 1500) {
      ahm = 3.2 * pow(log(11.75 * hm) / ln10, 2) - 4.97;
    } else if (_envType == 'urban-large') {
      ahm = 8.29 * pow(log(1.54 * hm) / ln10, 2) - 1.1;
    } else {
      ahm = (1.1 * log(freq) / ln10 - 0.7) * hm - (1.56 * log(freq) / ln10 - 0.8);
    }

    // Base path loss (urban)
    const hb = 30.0;
    final logF = log(freq) / ln10;
    final logHb = log(hb) / ln10;
    double pathLoss = 69.55 + 26.16 * logF - 13.82 * logHb - ahm + (44.9 - 6.55 * logHb) * (log(distance) / ln10);

    // Environment correction
    if (_envType == 'suburban') {
      pathLoss -= 2 * pow(log(freq / 28) / ln10, 2) + 5.4;
    } else if (_envType == 'open') {
      pathLoss -= 4.78 * pow(logF, 2) + 18.33 * logF - 40.94;
    }

    setState(() {
      _maplValue = pathLoss.roundToDouble();
      _distanceDisplay = distance;
    });

    // Save to history
    CalculationHistory.addEntry(HistoryEntry(
      frequency: _selectedFreq,
      gainAntenna: double.tryParse(_gainController.text) ?? 30,
      heightAntenna: hm,
      envType: _envType,
      distance: distance,
      mapl: pathLoss.round(),
      date: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _gainController.dispose();
    _heightController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CovantHeader(),
            const SizedBox(height: 8),

            const Text(
              'Okumura-Hata Calculator',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.gray800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Empirical formulation for predicting path loss in urban, suburban, and open areas.',
              style: TextStyle(fontSize: 13, color: AppTheme.gray500, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Frequency
            _buildLabel('Frequency'),
            const SizedBox(height: 8),
            _buildFreqSelector(),
            const SizedBox(height: 18),

            // Gain Antenna
            _buildLabel('Gain Antenna'),
            const SizedBox(height: 8),
            _buildInputField(_gainController, 'dBi'),
            const SizedBox(height: 18),

            // Height Antenna
            _buildLabel('Height Antenna'),
            const SizedBox(height: 8),
            _buildInputField(_heightController, 'm'),
            const SizedBox(height: 18),

            // Environment Type
            _buildLabel('Environment Type'),
            const SizedBox(height: 8),
            _buildEnvDropdown(),
            const SizedBox(height: 18),

            // Target Distance
            _buildLabel('Target Distance (km)'),
            const SizedBox(height: 8),
            _buildInputField(_distanceController, 'km'),
            const SizedBox(height: 24),

            // Compute Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _computePathLoss,
                icon: const Icon(Icons.calculate, size: 20),
                label: const Text('Compute Path Loss'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.navy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Result Diagram
            _buildResultDiagram(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.gray700),
    );
  }

  Widget _buildFreqSelector() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppTheme.gray100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _buildFreqBtn(900, '900 MHz'),
          _buildFreqBtn(1800, '1800 MHz'),
        ],
      ),
    );
  }

  Widget _buildFreqBtn(int freq, String label) {
    final isActive = _selectedFreq == freq;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFreq = freq),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.navy : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive
                ? [BoxShadow(color: AppTheme.navy.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppTheme.gray500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String unit) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.gray200, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(fontSize: 14, color: AppTheme.gray800),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
          suffixText: unit,
          suffixStyle: const TextStyle(fontSize: 12, color: AppTheme.gray400, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildEnvDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.gray200, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _envType,
          isExpanded: true,
          icon: const Icon(Icons.expand_more, color: AppTheme.gray400),
          style: const TextStyle(fontSize: 14, color: AppTheme.gray800, fontFamily: 'Inter'),
          items: _envLabels.entries.map((e) {
            return DropdownMenuItem(value: e.key, child: Text(e.value));
          }).toList(),
          onChanged: (v) => setState(() => _envType = v!),
        ),
      ),
    );
  }

  Widget _buildResultDiagram() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gray100),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Tower → Distance → City diagram
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Tower
                SizedBox(
                  width: 60,
                  child: CustomPaint(
                    size: const Size(60, 100),
                    painter: _TowerPainter(),
                  ),
                ),
                // Distance line
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Container(height: 2, color: AppTheme.navy),
                      const SizedBox(height: 4),
                      Text(
                        '${_distanceDisplay.toStringAsFixed(1)} km',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.navy),
                      ),
                    ],
                  ),
                ),
                // Buildings
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
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppTheme.gray100),
          const SizedBox(height: 16),
          // MAPL result
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text('MAPL: ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.gray500)),
              Text(
                '${_maplValue.round()}',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppTheme.navy),
              ),
              const Text(' dB', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.gray500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _building(double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: AppTheme.gray300,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
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

    // Main pole
    canvas.drawLine(Offset(cx, 10), Offset(cx, size.height), paint);

    // Upper arms
    canvas.drawLine(Offset(cx - 10, 20), Offset(cx, 10), paint..strokeWidth = 1.5);
    canvas.drawLine(Offset(cx + 10, 20), Offset(cx, 10), paint);

    // Mid supports
    canvas.drawLine(Offset(cx - 15, size.height * 0.7), Offset(cx, size.height * 0.45), paint..strokeWidth = 2);
    canvas.drawLine(Offset(cx + 15, size.height * 0.7), Offset(cx, size.height * 0.45), paint);

    // Base
    canvas.drawLine(Offset(cx - 20, size.height), Offset(cx, size.height * 0.65), paint);
    canvas.drawLine(Offset(cx + 20, size.height), Offset(cx, size.height * 0.65), paint);

    // Top dot
    final dotPaint = Paint()..color = AppTheme.blue..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, 8), 4, dotPaint);

    // Signal waves
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
