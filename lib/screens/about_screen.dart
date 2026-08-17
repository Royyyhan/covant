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
            _buildTeamGroup('Frontend Development', [
              _TeamMember('Ahmad Dani', 'Frontend Engineer', 'https://randomuser.me/api/portraits/men/32.jpg'),
              _TeamMember('Rina Sari', 'Frontend Engineer', 'https://randomuser.me/api/portraits/women/44.jpg'),
              _TeamMember('Budi Pratama', 'Frontend Engineer', 'https://randomuser.me/api/portraits/men/45.jpg'),
              _TeamMember('Siti Aminah', 'Frontend Engineer', 'https://randomuser.me/api/portraits/women/68.jpg'),
            ]),
            const SizedBox(height: 28),

            // Backend Development
            _buildTeamGroup('Backend Development', [
              _TeamMember('Eko Saputra', 'Backend Engineer', 'https://randomuser.me/api/portraits/men/52.jpg'),
              _TeamMember('Dian Lestari', 'Backend Engineer', 'https://randomuser.me/api/portraits/women/65.jpg'),
              _TeamMember('Agus Setiawan', 'Backend Engineer', 'https://randomuser.me/api/portraits/men/67.jpg'),
              _TeamMember('Maya Putri', 'Backend Engineer', 'https://randomuser.me/api/portraits/women/33.jpg'),
              _TeamMember('Hendra Kusuma', 'Backend Engineer', 'https://randomuser.me/api/portraits/men/75.jpg'),
              _TeamMember('Lina Marlina', 'Backend Engineer', 'https://randomuser.me/api/portraits/women/47.jpg'),
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
              child: Row(
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
                child: Column(
                  children: [
                    Icon(Icons.hub, size: 40, color: AppTheme.navy.withValues(alpha: 0.7)),
                    const SizedBox(height: 4),
                    const Text('pens', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.navy)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamGroup(String title, List<_TeamMember> members) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.blue)),
        const SizedBox(height: 14),
        ...members.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildTeamCard(m),
            )),
      ],
    );
  }

  Widget _buildTeamCard(_TeamMember member) {
    return Container(
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
            child: Image.network(
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(member.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.gray800)),
              const SizedBox(height: 2),
              Text(member.role, style: const TextStyle(fontSize: 12, color: AppTheme.gray500)),
            ],
          ),
        ],
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
  const _TeamMember(this.name, this.role, this.avatar);
}
