import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/theme.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData? icon;
  final Widget? trailing;

  const SectionCard({super.key, required this.title, required this.child, this.icon, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
            child: Row(children: [
              if (icon != null) ...[Icon(icon, size: 16, color: AppColors.accent), const SizedBox(width: 8)],
              Text(title, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
              const Spacer(),
              if (trailing != null) trailing!,
            ]),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}

class RiskBadge extends StatelessWidget {
  final String level;
  const RiskBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    String label;
    switch (level.toLowerCase()) {
      case 'high':   bg = const Color(0xFFFEE2E2); fg = AppColors.danger;  label = 'HIGH'; break;
      case 'medium': bg = const Color(0xFFFEF3C7); fg = AppColors.warning; label = 'MED';  break;
      default:       bg = const Color(0xFFDCFCE7); fg = AppColors.success; label = 'LOW';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(5)),
      child: Text(label, style: GoogleFonts.inter(color: fg, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}

class StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const StatBox({super.key, required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(value, style: GoogleFonts.inter(color: color ?? AppColors.accent, fontSize: 24, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11), textAlign: TextAlign.center),
      ]),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final bool outlined;
  const ActionButton({super.key, required this.label, required this.icon, this.onTap, this.color, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.accent;
    if (outlined) {
      return OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16, color: c),
        label: Text(label),
        style: OutlinedButton.styleFrom(foregroundColor: c, side: BorderSide(color: c),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      );
    }
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(backgroundColor: c, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
    );
  }
}

class ConnectionBanner extends StatelessWidget {
  final bool connected;
  const ConnectionBanner({super.key, required this.connected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: connected ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: connected ? AppColors.success : AppColors.danger)),
        const SizedBox(width: 6),
        Text(connected ? 'Backend Online' : 'Backend Offline',
            style: GoogleFonts.inter(color: connected ? AppColors.success : AppColors.danger, fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class InfoChip extends StatelessWidget {
  final String label;
  final Color? color;
  const InfoChip({super.key, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: c.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: GoogleFonts.inter(color: c, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }
}
