import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/theme.dart';
import '../widgets/common_widgets.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});
  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  List<Map<String, dynamic>> _services = [];

  @override
  void initState() {
    super.initState();
    final existing = context.read<AppState>().services;
    if (existing != null) _services = List<Map<String, dynamic>>.from(existing['services'] ?? []);
  }

  List<String> get _moduleIds {
    final m = context.read<AppState>().monolith;
    if (m == null) return [];
    return (m['modules'] as List).map((x) => x['id'] as String).toList();
  }

  void _snack(String msg, Color color) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg, style: GoogleFonts.inter(color: Colors.white)),
    backgroundColor: color, behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ));

  Future<void> _loadSample() async {
    final ok = await context.read<AppState>().loadSampleServices();
    if (ok && mounted) { setState(() => _services = List<Map<String, dynamic>>.from(context.read<AppState>().services!['services'] ?? [])); _snack('Sample services loaded!', AppColors.success); }
  }

  Future<void> _save() async {
    if (_services.isEmpty) { _snack('Add at least one service', AppColors.danger); return; }
    final ok = await context.read<AppState>().saveServices({'services': _services});
    if (ok && mounted) _snack('Services saved!', AppColors.success);
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AppState>().loading;
    final noMonolith = context.watch<AppState>().monolith == null;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text('Service Design', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        actions: [
          TextButton.icon(onPressed: _loadSample, icon: const Icon(Icons.auto_fix_high, size: 15), label: const Text('Load Sample')),
          const SizedBox(width: 8),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                if (noMonolith)
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFFDE68A))),
                    child: Row(children: [
                      const Icon(Icons.info_outline, color: AppColors.warning, size: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Text('Save monolith data first to map modules to services.', style: GoogleFonts.inter(color: AppColors.warning, fontSize: 12))),
                    ]),
                  ),
                SectionCard(
                  title: 'Microservices (${_services.length})',
                  icon: Icons.hub_rounded,
                  trailing: IconButton(icon: const Icon(Icons.add_circle_outline, color: AppColors.accent, size: 22), onPressed: _addService),
                  child: _services.isEmpty
                      ? Padding(padding: const EdgeInsets.all(24), child: Column(children: [
                          const Icon(Icons.hub_outlined, color: AppColors.textMuted, size: 40),
                          const SizedBox(height: 12),
                          Text('No services defined yet.', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text('Tap + or load sample data.', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11)),
                        ]))
                      : Column(children: _services.asMap().entries.map((e) => _svcTile(e.key, e.value)).toList()),
                ),
                SizedBox(width: double.infinity, child: ElevatedButton.icon(
                  onPressed: _save, icon: const Icon(Icons.save_rounded, size: 18), label: const Text('Save Services'),
                )),
                const SizedBox(height: 32),
              ]),
            ),
    );
  }

  Widget _svcTile(int idx, Map<String, dynamic> svc) {
    final mods = (svc['mapped_modules'] as List?)?.cast<String>() ?? [];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 11, 8, 6),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: AppColors.accentGlow, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.miscellaneous_services_rounded, color: AppColors.accent, size: 15)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(svc['name'] ?? '', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
              Text('${svc['id']} · ${svc['technology'] ?? ''} · Port: ${svc['port'] ?? '?'}',
                  style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.accentGlow, borderRadius: BorderRadius.circular(5)),
              child: Text('P${svc['priority'] ?? 1}', style: GoogleFonts.inter(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
            IconButton(icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary), onPressed: () => _editService(idx), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
            const SizedBox(width: 4),
            IconButton(icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.danger), onPressed: () => setState(() => _services.removeAt(idx)), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          ]),
        ),
        if (mods.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 2, 12, 10),
            child: Wrap(spacing: 6, runSpacing: 4,
                children: mods.map((m) => InfoChip(label: m, color: AppColors.success)).toList()),
          ),
      ]),
    );
  }

  void _addService() async { final r = await _svcDialog(null); if (r != null) setState(() => _services.add(r)); }
  void _editService(int idx) async { final r = await _svcDialog(_services[idx]); if (r != null) setState(() => _services[idx] = r); }

  Future<Map<String, dynamic>?> _svcDialog(Map<String, dynamic>? e) async {
    final idCtrl   = TextEditingController(text: e?['id'] ?? '');
    final nameCtrl = TextEditingController(text: e?['name'] ?? '');
    final descCtrl = TextEditingController(text: e?['description'] ?? '');
    final portCtrl = TextEditingController(text: e?['port']?.toString() ?? '');
    final techCtrl = TextEditingController(text: e?['technology'] ?? 'Python/FastAPI');
    int priority = e?['priority'] ?? 1;
    List<String> selected = List<String>.from(e?['mapped_modules'] ?? []);
    final allMods = _moduleIds;

    return showDialog<Map<String, dynamic>>(context: context, builder: (ctx) =>
      StatefulBuilder(builder: (ctx, ss) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(e == null ? 'Add Microservice' : 'Edit Microservice', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        content: SizedBox(width: 380, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: idCtrl, decoration: const InputDecoration(labelText: 'Service ID *', hintText: 'svc-auth')),
          const SizedBox(height: 10),
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Service Name *')),
          const SizedBox(height: 10),
          TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
          const SizedBox(height: 10),
          TextField(controller: techCtrl, decoration: const InputDecoration(labelText: 'Technology')),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: TextField(controller: portCtrl, decoration: const InputDecoration(labelText: 'Port'), keyboardType: TextInputType.number)),
            const SizedBox(width: 10),
            Expanded(child: DropdownButtonFormField<int>(
              initialValue: priority, decoration: const InputDecoration(labelText: 'Priority'),
              dropdownColor: AppColors.surface,
              items: [1,2,3,4,5].map((v) => DropdownMenuItem(value: v, child: Text('$v', style: GoogleFonts.inter(color: AppColors.textPrimary)))).toList(),
              onChanged: (v) => ss(() => priority = v!))),
          ]),
          if (allMods.isEmpty)
            Padding(padding: const EdgeInsets.only(top: 14), child: Text('Save monolith first to map modules.', style: GoogleFonts.inter(color: AppColors.warning, fontSize: 12)))
          else ...[
            const SizedBox(height: 14),
            Align(alignment: Alignment.centerLeft,
                child: Text('Map Monolith Modules:', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600))),
            const SizedBox(height: 6),
            ...allMods.map((mod) => CheckboxListTile(
              value: selected.contains(mod),
              title: Text(mod, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13)),
              activeColor: AppColors.accent, dense: true, contentPadding: EdgeInsets.zero,
              onChanged: (v) => ss(() { if (v == true) {
                selected.add(mod);
              } else {
                selected.remove(mod);
              } }),
            )),
          ],
        ]))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () {
            if (idCtrl.text.isEmpty || nameCtrl.text.isEmpty) return;
            Navigator.pop(ctx, {'id': idCtrl.text.trim(), 'name': nameCtrl.text.trim(), 'description': descCtrl.text.trim(),
              'technology': techCtrl.text.trim(), 'port': int.tryParse(portCtrl.text), 'priority': priority, 'mapped_modules': selected});
          }, child: const Text('Save')),
        ],
      )));
  }
}
