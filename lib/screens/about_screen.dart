import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/covant_header.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
              'DEVELOPMENT TEAM',
              style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: AppTheme.gray400, letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tim Pengembang',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.gray800),
            ),
            const SizedBox(height: 24),

            // Frontend Development
            _buildTeamGroup(context, 'Frontend Development', [
              const _TeamMember(
                'Mohammad Royhan Firdaus', 'Frontend Engineer',
                'lib/asset/foto/roy.png',
                'Politeknik Elektronika Negeri Surabaya', 'Teknik Informatika',
              ),
              const _TeamMember(
                'Faiq Muntashir', 'Frontend Engineer',
                'lib/asset/foto/faiq.png',
                'Politeknik Elektronika Negeri Surabaya', 'Teknik Informatika',
              ),
              const _TeamMember(
                'Daffa Afnandra W. P.', 'Frontend Engineer',
                'lib/asset/foto/daffa.png',
                'Politeknik Negeri Malang', 'Teknik Elektro',
              ),
              const _TeamMember(
                'Mochammat Choirur Roziqin', 'Frontend Engineer',
                'lib/asset/foto/zikin.png',
                'Politeknik Negeri Malang', 'Teknik Elektro',
              ),
            ]),
            const SizedBox(height: 28),

            // Backend Development
            _buildTeamGroup(context, 'Backend Development', [
              const _TeamMember(
                'Gilang Wahyu Setiawan', 'Backend Engineer',
                'lib/asset/foto/gilang.png',
                'Politeknik Negeri Malang', 'Teknik Elektro',
              ),
              const _TeamMember(
                'Arya Wijayanto', 'Backend Engineer',
                'lib/asset/foto/arya.png',
                'Politeknik Negeri Malang', 'Teknik Elektro',
              ),
              const _TeamMember(
                'Afif Amsal', 'Backend Engineer',
                'lib/asset/foto/afif.png',
                'Politeknik Negeri Malang', 'Teknik Elektro',
              ),
              const _TeamMember(
                'Ramadhania Permata Lestari', 'Backend Engineer',
                'lib/asset/foto/nia.png',
                'Politeknik Negeri Malang', 'Teknik Elektro',
              ),
              const _TeamMember(
                'Nova Adyamecca Azzahra', 'Backend Engineer',
                'lib/asset/foto/nova.png',
                'Politeknik Negeri Malang', 'Teknik Elektro',
              ),
              const _TeamMember(
                'Catur Hidayat Rahmatullah', 'Backend Engineer',
                'lib/asset/foto/catur.png',
                'Politeknik Elektronika Negeri Surabaya', 'Teknik Informatika',
              ),
            ]),
            const SizedBox(height: 32),

            // Collaborative Innovation
            Center(
              child: Text(
                'A COLLABORATIVE INNOVATION BY',
                style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w600,
                  color: AppTheme.gray400, letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // POCAGROUP
            _buildCollabCard(
              child: Center(
                child: Image.asset(
                  'lib/asset/foto/logo_poca.png',
                  height: 48,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Row(
                    children: [
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: AppTheme.navy,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Center(
                          child: Text('POCA', style: TextStyle(fontSize: 6, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('POCAGROUP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.navy)),
                          Text('PALING INDONESIA', style: TextStyle(fontSize: 9, color: AppTheme.gray400, letterSpacing: 2)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Polinema
            _buildCollabCard(
              child: Center(
                child: Image.asset(
                  'lib/asset/foto/Logo_Polinema.png',
                  height: 48,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Column(
                    children: [
                      Icon(Icons.school, size: 40, color: AppTheme.navy.withValues(alpha: 0.7)),
                      const SizedBox(height: 4),
                      const Text('POLINEMA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.navy)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // PENS
            _buildCollabCard(
              child: Center(
                child: Image.asset(
                  'lib/asset/foto/logo_pens.png',
                  height: 48,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Column(
                    children: [
                      Icon(Icons.hub, size: 40, color: AppTheme.navy.withValues(alpha: 0.7)),
                      const SizedBox(height: 4),
                      const Text('pens', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.navy)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamGroup(BuildContext context, String title, List<_TeamMember> members) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.blue)),
        const SizedBox(height: 14),
        ...members.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildTeamCard(context, m),
            )),
      ],
    );
  }

  Widget _buildTeamCard(BuildContext context, _TeamMember member) {
    return GestureDetector(
      onTap: () => _showMemberDetail(context, member),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.gray100),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                member.avatar,
                width: 44, height: 44, fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: AppTheme.gray100, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.person, color: AppTheme.gray400),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.gray800)),
                  const SizedBox(height: 2),
                  Text(member.role, style: const TextStyle(fontSize: 12, color: AppTheme.gray500)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: AppTheme.gray300),
          ],
        ),
      ),
    );
  }

  // ====================================================================
  //  MEMBER DETAIL POPUP
  // ====================================================================
  void _showMemberDetail(BuildContext context, _TeamMember member) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Close button row ──
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, right: 8),
                  child: IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.close_rounded, size: 22, color: AppTheme.gray400),
                    splashRadius: 20,
                  ),
                ),
              ),

              // ── Large Photo ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Image.asset(
                      member.avatar,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppTheme.gray100,
                        child: const Center(
                          child: Icon(Icons.person, size: 80, color: AppTheme.gray300),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Name ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  member.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.gray800,
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // ── Campus ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  member.campus,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.gray600,
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // ── Major / Jurusan ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  member.major,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.gray400,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollabCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gray100),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }
}

class _TeamMember {
  final String name;
  final String role;
  final String avatar;
  final String campus;
  final String major;
  const _TeamMember(this.name, this.role, this.avatar, this.campus, this.major);
}
