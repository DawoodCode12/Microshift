import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/theme.dart';
import '../widgets/common_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AppState>().checkConnection());
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppColors.surface,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: AppColors.border)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(20, 52, 20, 14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(color: AppColors.accentGlow, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.account_tree_rounded, color: AppColors.accent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('MicroShift', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
                      Text('Migration Planning Tool', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
                    ]),
                    const Spacer(),
                    ConnectionBanner(connected: state.backendConnected),
                  ]),
                ]),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(delegate: SliverChildListDelegate([
              if (!state.backendConnected) _offlineBanner(),
              _statsRow(state),
              const SizedBox(height: 16),
              _workflowCard(context, state),
              if (state.analysis != null) ...[const SizedBox(height: 4), _analysisSnapshot(state)],
              if (state.plan != null)     ...[const SizedBox(height: 4), _planSnapshot(context, state)],
              const SizedBox(height: 32),
            ])),
          ),
        ],
      ),
    );
  }

  Widget _offlineBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(children: [
        const Icon(Icons.wifi_off_rounded, color: AppColors.danger, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text('Backend not reachable. Start FastAPI on port 8000.',
            style: GoogleFonts.inter(color: AppColors.danger, fontSize: 13))),
      ]),
    );
  }

  Widget _statsRow(AppState state) {
    final modules = (state.monolith?['modules'] as List?)?.length ?? 0;
    final svcs    = (state.services?['services'] as List?)?.length ?? 0;
    final risk    = state.analysis?['overall_risk'] ?? '—';
    final steps   = (state.plan?['steps'] as List?)?.length ?? 0;
    Color rColor  = risk == 'high' ? AppColors.danger : risk == 'medium' ? AppColors.warning : AppColors.success;

    return GridView.count(
      crossAxisCount: 2, shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.7,
      children: [
        StatBox(label: 'Modules', value: '$modules'),
        StatBox(label: 'Services', value: '$svcs'),
        StatBox(label: 'Risk Level', value: risk == '—' ? '—' : risk.toUpperCase(), color: rColor),
        StatBox(label: 'Plan Steps', value: '$steps', color: AppColors.success),
      ],
    );
  }

  Widget _workflowCard(BuildContext context, AppState state) {
    final steps = [
      _Step('01', 'Monolith Input', 'Define modules & dependencies', Icons.view_module_rounded, '/monolith', state.monolith != null),
      _Step('02', 'Service Design', 'Map modules to microservices', Icons.hub_rounded, '/services', state.services != null),
      _Step('03', 'Risk Analysis', 'Detect dependencies & risks', Icons.analytics_rounded, '/analysis', state.analysis != null),
      _Step('04', 'Migration Plan', 'Step-by-step migration guide', Icons.map_rounded, '/plan', state.plan != null),
    ];
    return SectionCard(
      title: 'Workflow',
      icon: Icons.linear_scale_rounded,
      child: Column(children: steps.map((s) => _stepTile(context, s)).toList()),
    );
  }

  Widget _stepTile(BuildContext context, _Step s) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, s.route),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
        child: Row(children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: s.done ? const Color(0xFFDCFCE7) : AppColors.accentGlow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text(s.number,
                style: GoogleFonts.inter(color: s.done ? AppColors.success : AppColors.accent, fontSize: 11, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: 12),
          Icon(s.icon, size: 18, color: s.done ? AppColors.success : AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.title, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
            Text(s.subtitle, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11)),
          ])),
          if (s.done)
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 17)
          else
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 13),
        ]),
      ),
    );
  }

  Widget _analysisSnapshot(AppState state) {
    final a = state.analysis!;
    final summary = a['summary'] as Map? ?? {};
    return SectionCard(
      title: 'Risk Analysis',
      icon: Icons.shield_outlined,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Overall Risk: ', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
          RiskBadge(level: a['overall_risk'] ?? 'low'),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _miniStat('High Risk', '${summary['high_risk_modules'] ?? 0}', AppColors.danger)),
          const SizedBox(width: 8),
          Expanded(child: _miniStat('Med Risk', '${summary['medium_risk_modules'] ?? 0}', AppColors.warning)),
          const SizedBox(width: 8),
          Expanded(child: _miniStat('Unmapped', '${summary['unmapped_count'] ?? 0}', AppColors.textSecondary)),
        ]),
        if ((a['circular_dependencies'] as List?)?.isNotEmpty == true) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFFECACA))),
            child: Row(children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 16),
              const SizedBox(width: 8),
              Text('Circular dependencies detected!', style: GoogleFonts.inter(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: color.withOpacity(0.06), borderRadius: BorderRadius.circular(8)),
      child: Column(children: [
        Text(value, style: GoogleFonts.inter(color: color, fontSize: 20, fontWeight: FontWeight.w700)),
        Text(label, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 10)),
      ]),
    );
  }

  Widget _planSnapshot(BuildContext context, AppState state) {
    final plan = state.plan!;
    final summary = plan['summary'] as Map? ?? {};
    return SectionCard(
      title: 'Migration Plan',
      icon: Icons.map_outlined,
      trailing: TextButton(
        onPressed: () => Navigator.pushNamed(context, '/plan'),
        child: Text('View', style: GoogleFonts.inter(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(plan['pattern'] ?? '', style: GoogleFonts.inter(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(plan['pattern_description'] ?? '', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _miniStat('Steps', '${summary['total_steps'] ?? 0}', AppColors.accent)),
          const SizedBox(width: 8),
          Expanded(child: _miniStat('Services', '${summary['total_services_to_migrate'] ?? 0}', AppColors.success)),
          const SizedBox(width: 8),
          Expanded(child: _miniStat('Wks Est.', '${summary['estimated_duration_weeks'] ?? '?'}', AppColors.warning)),
        ]),
      ]),
    );
  }
}

class _Step {
  final String number, title, subtitle, route;
  final IconData icon;
  final bool done;
  const _Step(this.number, this.title, this.subtitle, this.icon, this.route, this.done);
}
