import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/covant_header.dart';
import '../main.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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

            // Hero Section
            const Text(
              'Selamat Datang di Covant.',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppTheme.gray800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Solusi teknis untuk analisis cakupan antena BTS. Platform terpadu untuk kalkulasi presisi dan visualisasi jaringan seluler.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.gray500,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),

            // Feature Card: Let's Calculate
            _FeatureCard(
              title: "Let's Calculate",
              description:
                  'Mulai perhitungan coverage antena BTS menggunakan model Okumura-Hata untuk hasil yang presisi.',
              buttonLabel: 'Mulai Hitung',
              onTap: () => mainNavKey.currentState?.switchToTab(1),
            ),
            const SizedBox(height: 16),

            // Feature Card: About Us
            _FeatureCard(
              title: 'About Us',
              description:
                  'Kenali tim di balik Covant dan mitra kolaborasi kami yang menghadirkan inovasi ini.',
              buttonLabel: 'Lihat Tim',
              onTap: () => mainNavKey.currentState?.switchToTab(3),
            ),
            const SizedBox(height: 32),

            // Powered By
            Center(
              child: Column(
                children: [
                  const Text(
                    'POWERED BY',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.gray400,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPartnerLogo('POLINEMA'),
                      const SizedBox(width: 24),
                      _buildPartnerLogo('POCAGROUP'),
                      const SizedBox(width: 24),
                      _buildPartnerLogo('PENS'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerLogo(String name) {
    return Opacity(
      opacity: 0.5,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          name,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppTheme.navy,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.gray100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.gray800,
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.blueLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    size: 18,
                    color: AppTheme.navy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.gray500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.navy,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}
