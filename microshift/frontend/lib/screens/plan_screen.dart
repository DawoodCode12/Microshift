import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/theme.dart';
import '../widgets/common_widgets.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  void _snack(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.inter(color: Colors.white)),
      backgroundColor: color, behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final plan  = state.plan;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text('Migration Plan', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        actions: [
          if (plan != null)
            TextButton.icon(
              onPressed: () => _export(context, state),
              icon: const Icon(Icons.download_rounded, size: 15),
              label: const Text('Export'),
            ),
          TextButton.icon(
            onPressed: state.loading ? null : () async {
              if (state.monolith == null) { _snack(context, 'Save monolith data first!', AppColors.warning); return; }
              await state.generatePlan();
            },
            icon: const Icon(Icons.bolt_rounded, size: 15),
            label: const Text('Generate'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: state.loading
          ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              CircularProgressIndicator(color: AppColors.accent),
              SizedBox(height: 16),
              Text('Generating migration plan…', style: TextStyle(color: AppColors.textSecondary)),
            ]))
          : plan == null ? _empty(context, state) : _content(context, plan),
    );
  }

  Future<void> _export(BuildContext context, AppState state) async {
    final md = await state.exportMarkdown();
    if (md == null || !context.mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(children: [
          const Icon(Icons.description_outlined, color: AppColors.accent, size: 18),
          const SizedBox(width: 8),
          Text('Migration Report', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        ]),
        content: SizedBox(width: 600, height: 480,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
              child: SingleChildScrollView(child: SelectableText(md, style: GoogleFonts.robotoMono(color: AppColors.textPrimary, fontSize: 11))),
            )),
        actions: [
          TextButton.icon(
            onPressed: () { Clipboard.setData(ClipboardData(text: md)); _snack(context, 'Copied!', AppColors.success); Navigator.pop(context); },
            icon: const Icon(Icons.copy_rounded, size: 14),
            label: const Text('Copy All'),
          ),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _empty(BuildContext context, AppState state) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: Color(0xFFFFFBEB), shape: BoxShape.circle),
            child: const Icon(Icons.map_outlined, color: AppColors.warning, size: 44)),
        const SizedBox(height: 20),
        Text('No Migration Plan Yet', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text('Complete Steps 1–3, then tap Generate.', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        ActionButton(label: 'Generate Plan', icon: Icons.bolt_rounded,
            onTap: state.monolith == null ? null : () => state.generatePlan(), color: AppColors.warning),
      ]),
    ));
  }

  Widget _content(BuildContext context, Map<String, dynamic> plan) {
    final steps   = (plan['steps'] as List?)?.cast<Map>() ?? [];
    final summary = plan['summary'] as Map? ?? {};
    final risks   = (plan['continuity_risks'] as List?)?.cast<Map>() ?? [];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header card
        Container(
          padding: const EdgeInsets.all(18),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.account_tree_rounded, color: AppColors.accent, size: 18),
              const SizedBox(width: 8),
              Text(plan['pattern'] ?? '', style: GoogleFonts.inter(color: AppColors.accent, fontSize: 14, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 6),
            Text(plan['pattern_description'] ?? '', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _hStat('Steps', '${summary['total_steps'] ?? 0}')),
              Expanded(child: _hStat('Services', '${summary['total_services_to_migrate'] ?? 0}')),
              Expanded(child: _hStat('Est. Weeks', '${summary['estimated_duration_weeks'] ?? '?'}')),
              Expanded(child: _hStat('Team Size', '${summary['recommended_team_size'] ?? '?'}')),
            ]),
          ]),
        ),

        // Business continuity risks
        if (risks.isNotEmpty)
          SectionCard(
            title: 'Business Continuity Risks',
            icon: Icons.security_outlined,
            child: Column(children: risks.map((r) => _riskCard(r)).toList()),
          ),

        // Migration steps
        SectionCard(
          title: 'Migration Steps',
          icon: Icons.format_list_numbered_rounded,
          child: Column(children: steps.map((s) => _stepCard(s)).toList()),
        ),
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _hStat(String label, String value) {
    return Column(children: [
      Text(value, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
      Text(label, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 10)),
    ]);
  }

  Widget _riskCard(Map r) {
    final c = r['severity'] == 'high' ? AppColors.danger : AppColors.warning;
    final bg = r['severity'] == 'high' ? const Color(0xFFFEF2F2) : const Color(0xFFFFFBEB);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: c.withOpacity(0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(r['severity'] == 'high' ? Icons.dangerous_rounded : Icons.warning_amber_rounded, color: c, size: 15),
          const SizedBox(width: 7),
          Expanded(child: Text(r['risk'] ?? '', style: GoogleFonts.inter(color: c, fontSize: 13, fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 5),
        Text('Impact: ${r['impact']}', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 3),
        Text('Mitigation: ${r['mitigation']}', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 12)),
      ]),
    );
  }

  Widget _stepCard(Map step) {
    final level   = step['risk_level'] as String? ?? 'low';
    final downtime = step['downtime_risk'] == true;
    final rColor  = level == 'high' ? AppColors.danger : level == 'medium' ? AppColors.warning : AppColors.success;
    final rBg     = level == 'high' ? const Color(0xFFFEF2F2) : level == 'medium' ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDF4);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Step header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(color: rBg, borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), border: const Border(bottom: BorderSide(color: AppColors.border))),
          child: Row(children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(shape: BoxShape.circle, color: rColor.withOpacity(0.15), border: Border.all(color: rColor.withOpacity(0.4))),
              child: Center(child: Text('${step['step']}', style: GoogleFonts.inter(color: rColor, fontSize: 12, fontWeight: FontWeight.w700))),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(step['title'] ?? '', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
              Text('${step['phase']}  ·  ${step['estimated_duration'] ?? ''}',
                  style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11)),
            ])),
            RiskBadge(level: level),
            if (downtime) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(5)),
                child: Text('⚠ Downtime', style: GoogleFonts.inter(color: AppColors.danger, fontSize: 10, fontWeight: FontWeight.w600)),
              ),
            ],
          ]),
        ),
        // Step body
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(step['description'] ?? '', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 10),
            Text('Actions', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            ...(step['actions'] as List? ?? []).map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Padding(padding: EdgeInsets.only(top: 2), child: Icon(Icons.chevron_right_rounded, size: 15, color: AppColors.accent)),
                const SizedBox(width: 4),
                Expanded(child: Text('$a', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12))),
              ]),
            )),
            if ((step['continuity_notes'] ?? '').toString().isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(color: AppColors.accentGlow, borderRadius: BorderRadius.circular(8)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.tips_and_updates_outlined, color: AppColors.accent, size: 14),
                  const SizedBox(width: 8),
                  Expanded(child: Text('${step['continuity_notes']}',
                      style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 11))),
                ]),
              ),
            ],
          ]),
        ),
      ]),
    );
  }
}
