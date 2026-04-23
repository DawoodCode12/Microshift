import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'services/theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/monolith_screen.dart';
import 'screens/services_screen.dart';
import 'screens/analysis_screen.dart';
import 'screens/plan_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MicroShiftApp(),
    ),
  );
}

class MicroShiftApp extends StatelessWidget {
  const MicroShiftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MicroShift',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _labels = ['Dashboard', 'Monolith', 'Services', 'Analysis', 'Plan'];
  static const _icons  = [
    Icons.dashboard_rounded,
    Icons.view_module_rounded,
    Icons.hub_rounded,
    Icons.analytics_rounded,
    Icons.map_rounded,
  ];

  static const _screens = [
    DashboardScreen(),
    MonolithScreen(),
    ServicesScreen(),
    AnalysisScreen(),
    PlanScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 700;

    if (wide) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: Row(children: [
          _Sidebar(index: _index, onTap: (i) => setState(() => _index = i), labels: _labels, icons: _icons),
          const VerticalDivider(width: 1, color: AppColors.border),
          Expanded(child: _screens[_index]),
        ]),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _screens[_index],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
          color: AppColors.surface,
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.textMuted,
          selectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 10),
          items: List.generate(_labels.length, (i) => BottomNavigationBarItem(
            icon: Icon(_icons[i], size: 22),
            label: _labels[i],
          )),
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  final List<String> labels;
  final List<IconData> icons;

  const _Sidebar({required this.index, required this.onTap, required this.labels, required this.icons});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      color: AppColors.surface,
      child: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.accentGlow, borderRadius: BorderRadius.circular(9)),
                child: const Icon(Icons.account_tree_rounded, color: AppColors.accent, size: 18),
              ),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('MicroShift', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
                Text('Migration Tool', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 10)),
              ]),
            ]),
          ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 8),
          ...List.generate(labels.length, (i) {
            final selected = index == i;
            return GestureDetector(
              onTap: () => onTap(i),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.accentGlow : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  Icon(icons[i], size: 18, color: selected ? AppColors.accent : AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Text(labels[i], style: GoogleFonts.inter(
                    color: selected ? AppColors.accent : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  )),
                ]),
              ),
            );
          }),
        ]),
      ),
    );
  }
}
