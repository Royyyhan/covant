import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../main.dart';

/// Logo color matching the CovAnt logo image
const Color _logoBlue = Color(0xFF2E3B8C);

class CovantHeader extends StatelessWidget {
  const CovantHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: GestureDetector(
        onTap: () => mainNavKey.currentState?.switchToTab(0),
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'lib/asset/foto/CovAnt.png',
              height: 36,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => SizedBox(
                width: 19,
                height: 19,
                child: CustomPaint(painter: _LogoPainter()),
              ),
            ),
            const SizedBox(width: 7),
            Text(
              'COVANT',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: _logoBlue,
                letterSpacing: -1.2,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.navy
      ..style = PaintingStyle.fill;

    // Draw stacked layers icon
    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Top layer
    path.moveTo(cx, cy - 8);
    path.lineTo(cx - 12, cy - 2);
    path.lineTo(cx, cy + 4);
    path.lineTo(cx + 12, cy - 2);
    path.close();
    canvas.drawPath(path, paint);

    // Middle layer (stroke)
    final strokePaint = Paint()
      ..color = AppTheme.navy
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(cx - 12, cy + 2), Offset(cx, cy + 8), strokePaint);
    canvas.drawLine(Offset(cx, cy + 8), Offset(cx + 12, cy + 2), strokePaint);

    // Bottom layer
    canvas.drawLine(Offset(cx - 12, cy + 6), Offset(cx, cy + 12), strokePaint);
    canvas.drawLine(Offset(cx, cy + 12), Offset(cx + 12, cy + 6), strokePaint);

    // Blue dot
    canvas.drawCircle(Offset(cx, cy - 4), 2.5, Paint()..color = AppTheme.blue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
