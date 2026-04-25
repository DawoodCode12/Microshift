import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/theme.dart';
import '../widgets/common_widgets.dart';

class MonolithScreen extends StatefulWidget {
  const MonolithScreen({super.key});
  @override
  State<MonolithScreen> createState() => _MonolithScreenState();
}

class _MonolithScreenState extends State<MonolithScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  List<Map<String, dynamic>> _modules = [];
  List<Map<String, dynamic>> _dependencies = [];

  @override
  void initState() {
    super.initState();
    final existing = context.read<AppState>().monolith;
    if (existing != null) _loadFromData(existing);
  }

  void _loadFromData(Map<String, dynamic> d) {
    _nameCtrl.text = d['system_name'] ?? '';
    _descCtrl.text = d['description'] ?? '';
    _modules = List<Map<String, dynamic>>.from(d['modules'] ?? []);
    _dependencies = List<Map<String, dynamic>>.from(d['dependencies'] ?? []);
    setState(() {});
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.inter(color: Colors.white)),
      backgroundColor: color, behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }

  Future<void> _loadSample() async {
    final ok = await context.read<AppState>().loadSampleMonolith();
    if (ok && mounted) { _loadFromData(context.read<AppState>().monolith!); _snack('Sample loaded!', AppColors.success); }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) { _snack('Enter a system name', AppColors.danger); return; }
    if (_modules.isEmpty) { _snack('Add at least one module', AppColors.danger); return; }
    final ok = await context.read<AppState>().saveMonolith({
      'system_name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'modules': _modules,
      'dependencies': _dependencies,
    });
    if (ok && mounted) _snack('Saved successfully!', AppColors.success);
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AppState>().loading;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text('Monolith Input', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        actions: [
          TextButton.icon(
            onPressed: _loadSample,
            icon: const Icon(Icons.auto_fix_high, size: 15),
            label: const Text('Load Sample'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                SectionCard(
                  title: 'System Info',
                  icon: Icons.info_outline_rounded,
                  child: Column(children: [
                    TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'System Name *', hintText: 'e.g. Library Management System')),
                    const SizedBox(height: 12),
                    TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description', hintText: 'Brief description'), maxLines: 2),
                  ]),
                ),
                SectionCard(
                  title: 'Modules (${_modules.length})',
                  icon: Icons.view_module_rounded,
                  trailing: IconButton(icon: const Icon(Icons.add_circle_outline, color: AppColors.accent, size: 22), onPressed: _addModule),
                  child: _modules.isEmpty
                      ? _emptyState('No modules yet. Tap + or Load Sample.')
                      : Column(children: _modules.asMap().entries.map((e) => _moduleTile(e.key, e.value)).toList()),
                ),
                SectionCard(
                  title: 'Dependencies (${_dependencies.length})',
                  icon: Icons.share_rounded,
                  trailing: IconButton(icon: const Icon(Icons.add_circle_outline, color: AppColors.accent, size: 22), onPressed: _addDep),
                  child: _dependencies.isEmpty
                      ? _emptyState('No dependencies yet. Add modules first.')
                      : Column(children: _dependencies.asMap().entries.map((e) => _depTile(e.key, e.value)).toList()),
                ),
                SizedBox(width: double.infinity, child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: const Text('Save Monolith Data'),
                )),
                const SizedBox(height: 32),
              ]),
            ),
    );
  }

  Widget _emptyState(String text) => Padding(
    padding: const EdgeInsets.all(20),
    child: Center(child: Text(text, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13), textAlign: TextAlign.center)),
  );

  Widget _moduleTile(int idx, Map<String, dynamic> m) {
    final layerColors = {'ui': AppColors.accent, 'business': AppColors.success, 'data': AppColors.warning, 'integration': const Color(0xFF7C3AED)};
    final c = layerColors[m['layer']] ?? AppColors.textSecondary;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Container(width: 3, height: 38, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(m['name'] ?? '', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
          Text('${m['id']} · ${m['layer']} · ${m['complexity']}', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11)),
        ])),
        RiskBadge(level: m['complexity'] ?? 'medium'),
        const SizedBox(width: 4),
        IconButton(icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary), onPressed: () => _editModule(idx), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
        const SizedBox(width: 8),
        IconButton(icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.danger), onPressed: () => _deleteModule(idx), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
      ]),
    );
  }

  Widget _depTile(int idx, Map<String, dynamic> d) {
    final c = {'high': AppColors.danger, 'medium': AppColors.warning, 'low': AppColors.success}[d['strength']] ?? AppColors.textSecondary;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Expanded(child: Row(children: [
          Text(d['from_module'] ?? '', style: GoogleFonts.inter(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w600)),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('—${d['type']}→', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11))),
          Text(d['to_module'] ?? '', style: GoogleFonts.inter(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600)),
        ])),
        InfoChip(label: d['strength'] ?? '', color: c),
        const SizedBox(width: 8),
        IconButton(icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.danger), onPressed: () => setState(() => _dependencies.removeAt(idx)), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
      ]),
    );
  }

  void _deleteModule(int idx) {
    final id = _modules[idx]['id'];
    setState(() {
      _modules.removeAt(idx);
      _dependencies.removeWhere((d) => d['from_module'] == id || d['to_module'] == id);
    });
  }

  void _addModule() async { final r = await _moduleDialog(null); if (r != null) setState(() => _modules.add(r)); }
  void _editModule(int idx) async { final r = await _moduleDialog(_modules[idx]); if (r != null) setState(() => _modules[idx] = r); }
  void _addDep() async {
    if (_modules.length < 2) { _snack('Need at least 2 modules first', AppColors.warning); return; }
    final r = await _depDialog();
    if (r != null) setState(() => _dependencies.add(r));
  }

  Future<Map<String, dynamic>?> _moduleDialog(Map<String, dynamic>? e) async {
    final idCtrl   = TextEditingController(text: e?['id'] ?? '');
    final nameCtrl = TextEditingController(text: e?['name'] ?? '');
    final descCtrl = TextEditingController(text: e?['description'] ?? '');
    String layer = e?['layer'] ?? 'business';
    String complexity = e?['complexity'] ?? 'medium';
    return showDialog<Map<String, dynamic>>(context: context, builder: (ctx) =>
      StatefulBuilder(builder: (ctx, ss) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(e == null ? 'Add Module' : 'Edit Module', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: idCtrl, decoration: const InputDecoration(labelText: 'ID *', hintText: 'e.g. auth')),
          const SizedBox(height: 10),
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name *')),
          const SizedBox(height: 10),
          TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(initialValue: layer, decoration: const InputDecoration(labelText: 'Layer'),
            dropdownColor: AppColors.surface,
            items: ['ui','business','data','integration'].map((v) => DropdownMenuItem(value: v, child: Text(v, style: GoogleFonts.inter(color: AppColors.textPrimary)))).toList(),
            onChanged: (v) => ss(() => layer = v!)),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(initialValue: complexity, decoration: const InputDecoration(labelText: 'Complexity'),
            dropdownColor: AppColors.surface,
            items: ['low','medium','high'].map((v) => DropdownMenuItem(value: v, child: Text(v, style: GoogleFonts.inter(color: AppColors.textPrimary)))).toList(),
            onChanged: (v) => ss(() => complexity = v!)),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () {
            if (idCtrl.text.isEmpty || nameCtrl.text.isEmpty) return;
            Navigator.pop(ctx, {'id': idCtrl.text.trim().replaceAll(' ', '_'), 'name': nameCtrl.text.trim(), 'description': descCtrl.text.trim(), 'layer': layer, 'complexity': complexity});
          }, child: const Text('Save')),
        ],
      )));
  }

  Future<Map<String, dynamic>?> _depDialog() async {
    final ids = _modules.map((m) => m['id'] as String).toList();
    String from = ids[0], to = ids[1], type = 'uses', strength = 'medium';
    return showDialog<Map<String, dynamic>>(context: context, builder: (ctx) =>
      StatefulBuilder(builder: (ctx, ss) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Add Dependency', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<String>(initialValue: from, decoration: const InputDecoration(labelText: 'From Module'),
            dropdownColor: AppColors.surface,
            items: ids.map((v) => DropdownMenuItem(value: v, child: Text(v, style: GoogleFonts.inter(color: AppColors.textPrimary)))).toList(),
            onChanged: (v) => ss(() => from = v!)),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(initialValue: to, decoration: const InputDecoration(labelText: 'To Module'),
            dropdownColor: AppColors.surface,
            items: ids.map((v) => DropdownMenuItem(value: v, child: Text(v, style: GoogleFonts.inter(color: AppColors.textPrimary)))).toList(),
            onChanged: (v) => ss(() => to = v!)),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(initialValue: type, decoration: const InputDecoration(labelText: 'Type'),
            dropdownColor: AppColors.surface,
            items: ['uses','calls','reads','writes'].map((v) => DropdownMenuItem(value: v, child: Text(v, style: GoogleFonts.inter(color: AppColors.textPrimary)))).toList(),
            onChanged: (v) => ss(() => type = v!)),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(initialValue: strength, decoration: const InputDecoration(labelText: 'Strength'),
            dropdownColor: AppColors.surface,
            items: ['low','medium','high'].map((v) => DropdownMenuItem(value: v, child: Text(v, style: GoogleFonts.inter(color: AppColors.textPrimary)))).toList(),
            onChanged: (v) => ss(() => strength = v!)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, {'from_module': from, 'to_module': to, 'type': type, 'strength': strength}), child: const Text('Add')),
        ],
      )));
  }
}
