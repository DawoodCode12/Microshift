import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Change this to your Railway URL after deployment:
  // static const String baseUrl = 'https://your-app.up.railway.app';
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<Map<String, dynamic>> get(String path) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('GET $path failed: ${response.statusCode} ${response.body}');
    }
  }

  static Future<String> getRaw(String path) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('GET $path failed: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('POST $path failed: ${response.statusCode} ${response.body}');
    }
  }

  // Monolith
  static Future<Map<String, dynamic>> saveMonolith(Map<String, dynamic> data) => post('/monolith/save', data);
  static Future<Map<String, dynamic>> loadMonolith() => get('/monolith/load');
  static Future<Map<String, dynamic>> getSampleMonolith() => get('/monolith/sample');

  // Services
  static Future<Map<String, dynamic>> saveServices(Map<String, dynamic> data) => post('/services/save', data);
  static Future<Map<String, dynamic>> loadServices() => get('/services/load');
  static Future<Map<String, dynamic>> getSampleServices() => get('/services/sample');

  // Analysis
  static Future<Map<String, dynamic>> runAnalysis() => get('/analysis/run');
  static Future<Map<String, dynamic>> loadAnalysis() => get('/analysis/load');

  // Migration
  static Future<Map<String, dynamic>> generatePlan() => get('/migration/generate');
  static Future<Map<String, dynamic>> loadPlan() => get('/migration/load');

  // Export
  static Future<String> exportMarkdown() => getRaw('/export/markdown');
  static Future<Map<String, dynamic>> exportJson() => get('/export/json');

  // Health check
  static Future<bool> checkHealth() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/health')).timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
