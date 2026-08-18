import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'screens/calculator_screen.dart';
import 'screens/history_screen.dart';
import 'screens/about_screen.dart';
import 'theme/app_theme.dart';
import 'models/calculation_history.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  await CalculationHistory.init();
  runApp(const CovantApp());
}

/// Global navigation key to switch tabs from any screen
final GlobalKey<MainNavigationState> mainNavKey = GlobalKey<MainNavigationState>();

class CovantApp extends StatelessWidget {
  const CovantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'COVANT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: MainNavigation(key: mainNavKey),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  void switchToTab(int index) {
    setState(() => _currentIndex = index);
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    CalculatorScreen(),
    HistoryScreen(),
    AboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
                _buildNavItem(1, Icons.calculate_outlined, Icons.calculate, 'Calculator'),
                _buildNavItem(2, Icons.history_outlined, Icons.history, 'History'),
                _buildNavItem(3, Icons.info_outline, Icons.info, 'About'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => switchToTab(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFDBEAFE) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 22,
              color: isActive ? AppTheme.navy : const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? AppTheme.navy : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
