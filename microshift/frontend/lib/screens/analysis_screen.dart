import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/theme.dart';
import '../widgets/common_widgets.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final analysis = state.analysis;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text('Risk Analysis', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        actions: [
          TextButton.icon(
            onPressed: state.loading ? null : () async {
              if (state.monolith == null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Save monolith data first!', style: GoogleFonts.inter(color: Colors.white)),
                  backgroundColor: AppColors.warning, behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ));
                return;
              }
              await state.runAnalysis();
            },
            icon: const Icon(Icons.play_arrow_rounded, size: 16),
            label: const Text('Run Analysis'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: state.loading
          ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              CircularProgressIndicator(color: AppColors.accent),
              SizedBox(height: 16),
              Text('Analysing dependencies…', style: TextStyle(color: AppColors.textSecondary)),
            ]))
          : analysis == null
              ? _empty(context, state)
              : _content(analysis),
    );
  }

  Widget _empty(BuildContext context, AppState state) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.accentGlow, shape: BoxShape.circle),
            child: const Icon(Icons.analytics_outlined, color: AppColors.accent, size: 44)),
        const SizedBox(height: 20),
        Text('No analysis yet', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text('Save monolith data, then tap Run Analysis.', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        ActionButton(label: 'Run Analysis', icon: Icons.analytics_rounded,
            onTap: state.monolith == null ? null : () => state.runAnalysis()),
      ]),
    ));
  }

  Widget _content(Map<String, dynamic> a) {
    final summary   = a['summary'] as Map? ?? {};
    final risks     = (a['module_risks'] as List?)?.cast<Map>() ?? [];
    final crossDeps = (a['cross_service_dependencies'] as List?)?.cast<Map>() ?? [];
    final cycles    = (a['circular_dependencies'] as List?)?.cast<String>() ?? [];
    final unmapped  = (a['unmapped_modules'] as List?)?.cast<String>() ?? [];
    final overall   = a['overall_risk'] as String? ?? 'low';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Overall risk banner
        Container(
          padding: const EdgeInsets.all(18),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: _riskBg(overall),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _riskColor(overall).withOpacity(0.3)),
          ),
          child: Row(children: [
            Icon(_riskIcon(overall), color: _riskColor(overall), size: 32),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Overall Risk Level', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
              Text(overall.toUpperCase(), style: GoogleFonts.inter(color: _riskColor(overall), fontSize: 24, fontWeight: FontWeight.w700)),
            ]),
            const Spacer(),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${summary['total_modules'] ?? 0}', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
              Text('modules', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11)),
            ]),
          ]),
        ),

        // Stats row
        Row(children: [
          Expanded(child: StatBox(label: 'High Risk', value: '${summary['high_risk_modules'] ?? 0}', color: AppColors.danger)),
          const SizedBox(width: 10),
          Expanded(child: StatBox(label: 'Med Risk',  value: '${summary['medium_risk_modules'] ?? 0}', color: AppColors.warning)),
          const SizedBox(width: 10),
          Expanded(child: StatBox(label: 'Low Risk',  value: '${summary['low_risk_modules'] ?? 0}', color: AppColors.success)),
        ]),
        const SizedBox(height: 16),

        // Alerts
        if (cycles.isNotEmpty) _alert('Circular Dependencies Detected', cycles.join('\n'), AppColors.danger, Icons.loop_rounded),
        if (unmapped.isNotEmpty) _alert('Unmapped Modules', unmapped.join(', '), AppColors.warning, Icons.warning_amber_rounded),
        if (a['shared_data_risk'] == true) _alert('Shared Database Risk', 'Multiple modules share the same database, creating tight coupling.', AppColors.warning, Icons.storage_rounded),

        // Module risk table
        SectionCard(
          title: 'Module Risk Table',
          icon: Icons.table_chart_outlined,
          child: Column(children: risks.map((r) => _riskRow(r)).toList()),
        ),

        // Cross-service deps
        if (crossDeps.isNotEmpty)
          SectionCard(
            title: 'Cross-Service Dependencies (${crossDeps.length})',
            icon: Icons.swap_horiz_rounded,
            child: Column(children: crossDeps.map((d) => _crossRow(d)).toList()),
          ),
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _alert(String title, String message, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withOpacity(0.07), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.25))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(title, style: GoogleFonts.inter(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 6),
        Text(message, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
      ]),
    );
  }

  Widget _riskRow(Map r) {
    final level = r['risk_level'] as String? ?? 'low';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(r['module_name'] ?? '', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
          Text('In: ${r['incoming_deps']}  Out: ${r['outgoing_deps']}  ·  ${r['layer']}',
              style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11)),
        ])),
        Text('${r['risk_score']}', style: GoogleFonts.inter(color: _riskColor(level), fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(width: 10),
        RiskBadge(level: level),
      ]),
    );
  }

  Widget _crossRow(Map d) {
    final c = {'high': AppColors.danger, 'medium': AppColors.warning, 'low': AppColors.success}[d['strength']] ?? AppColors.textSecondary;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(d['from_service'] ?? '', style: GoogleFonts.inter(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w600)),
            Text(' → ', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
            Text(d['to_service'] ?? '', style: GoogleFonts.inter(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
          Text('via ${d['via_modules']} (${d['type']})', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11)),
        ])),
        InfoChip(label: d['strength'] ?? '', color: c),
      ]),
    );
  }

  Color _riskColor(String l) => l == 'high' ? AppColors.danger : l == 'medium' ? AppColors.warning : AppColors.success;
  Color _riskBg(String l) => l == 'high' ? const Color(0xFFFEF2F2) : l == 'medium' ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDF4);
  IconData _riskIcon(String l) => l == 'high' ? Icons.dangerous_rounded : l == 'medium' ? Icons.warning_amber_rounded : Icons.check_circle_rounded;
}
