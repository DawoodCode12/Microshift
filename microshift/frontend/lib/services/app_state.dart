import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  bool _backendConnected = false;
  bool _loading = false;
  String? _error;

  Map<String, dynamic>? _monolith;
  Map<String, dynamic>? _services;
  Map<String, dynamic>? _analysis;
  Map<String, dynamic>? _plan;

  bool get backendConnected => _backendConnected;
  bool get loading => _loading;
  String? get error => _error;
  Map<String, dynamic>? get monolith => _monolith;
  Map<String, dynamic>? get services => _services;
  Map<String, dynamic>? get analysis => _analysis;
  Map<String, dynamic>? get plan => _plan;

  void setLoading(bool v) { _loading = v; notifyListeners(); }
  void setError(String? e) { _error = e; notifyListeners(); }

  Future<void> checkConnection() async {
    _backendConnected = await ApiService.checkHealth();
    notifyListeners();
  }

  Future<bool> loadSampleMonolith() async {
    setLoading(true); setError(null);
    try {
      _monolith = await ApiService.getSampleMonolith();
      notifyListeners();
      return true;
    } catch (e) { setError(e.toString()); return false; }
    finally { setLoading(false); }
  }

  Future<bool> saveMonolith(Map<String, dynamic> data) async {
    setLoading(true); setError(null);
    try {
      await ApiService.saveMonolith(data);
      _monolith = data;
      notifyListeners();
      return true;
    } catch (e) { setError(e.toString()); return false; }
    finally { setLoading(false); }
  }

  Future<bool> loadSampleServices() async {
    setLoading(true); setError(null);
    try {
      _services = await ApiService.getSampleServices();
      notifyListeners();
      return true;
    } catch (e) { setError(e.toString()); return false; }
    finally { setLoading(false); }
  }

  Future<bool> saveServices(Map<String, dynamic> data) async {
    setLoading(true); setError(null);
    try {
      await ApiService.saveServices(data);
      _services = data;
      notifyListeners();
      return true;
    } catch (e) { setError(e.toString()); return false; }
    finally { setLoading(false); }
  }

  Future<bool> runAnalysis() async {
    setLoading(true); setError(null);
    try {
      _analysis = await ApiService.runAnalysis();
      notifyListeners();
      return true;
    } catch (e) { setError(e.toString()); return false; }
    finally { setLoading(false); }
  }

  Future<bool> generatePlan() async {
    setLoading(true); setError(null);
    try {
      _plan = await ApiService.generatePlan();
      notifyListeners();
      return true;
    } catch (e) { setError(e.toString()); return false; }
    finally { setLoading(false); }
  }

  Future<String?> exportMarkdown() async {
    setLoading(true); setError(null);
    try {
      final md = await ApiService.exportMarkdown();
      return md;
    } catch (e) { setError(e.toString()); return null; }
    finally { setLoading(false); }
  }
}
