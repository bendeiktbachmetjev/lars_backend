import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  ApiService._internal();
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  String _baseUrl = apiBaseUrl;

  // Set base URL if backend is remote
  void setBaseUrl(String url) {
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  // Patient code persistence
  static const _patientCodeKey = 'patient_code';

  Future<void> savePatientCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_patientCodeKey, code.trim().toUpperCase());
  }

  Future<String?> getPatientCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_patientCodeKey);
  }

  Future<void> clearPatientCode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_patientCodeKey);
  }

  Map<String, String> _headers(String patientCode) => <String, String>{
        'Content-Type': 'application/json',
        'X-Patient-Code': patientCode,
      };

  Future<http.Response> sendWeekly({
    required String patientCode,
    required int flatusControl,
    required int liquidStoolLeakage,
    required int bowelFrequency,
    required int repeatBowelOpening,
    required int urgencyToToilet,
    String? entryDate,
    Map<String, dynamic>? rawData,
  }) async {
    final uri = Uri.parse('$_baseUrl/sendWeekly');
    final body = jsonEncode({
      'flatus_control': flatusControl,
      'liquid_stool_leakage': liquidStoolLeakage,
      'bowel_frequency': bowelFrequency,
      'repeat_bowel_opening': repeatBowelOpening,
      'urgency_to_toilet': urgencyToToilet,
      'entry_date': entryDate,
      'raw_data': rawData,
    });
    return http.post(uri, headers: _headers(patientCode), body: body);
  }

  Future<http.Response> sendDaily({
    required String patientCode,
    int? bristolScale,
    String? entryDate,
    Map<String, dynamic>? foodConsumption,
    Map<String, dynamic>? drinkConsumption,
    Map<String, dynamic>? rawData,
  }) async {
    final uri = Uri.parse('$_baseUrl/sendDaily');
    final body = jsonEncode({
      'entry_date': entryDate,
      'bristol_scale': bristolScale,
      'food_consumption': foodConsumption,
      'drink_consumption': drinkConsumption,
      'raw_data': rawData,
    });
    return http.post(uri, headers: _headers(patientCode), body: body);
  }

  Future<http.Response> sendMonthly({
    required String patientCode,
    int? qolScore,
    String? entryDate,
    Map<String, dynamic>? rawData,
  }) async {
    final uri = Uri.parse('$_baseUrl/sendMonthly');
    final body = jsonEncode({
      'entry_date': entryDate,
      'qol_score': qolScore,
      'raw_data': rawData,
    });
    return http.post(uri, headers: _headers(patientCode), body: body);
  }

  Future<http.Response> sendEq5d5l({
    required String patientCode,
    required int mobility,
    required int selfCare,
    required int usualActivities,
    required int painDiscomfort,
    required int anxietyDepression,
    int? healthVas,
    String? entryDate,
    Map<String, dynamic>? rawData,
  }) async {
    final uri = Uri.parse('$_baseUrl/sendEq5d5l');
    final body = jsonEncode({
      'mobility': mobility,
      'self_care': selfCare,
      'usual_activities': usualActivities,
      'pain_discomfort': painDiscomfort,
      'anxiety_depression': anxietyDepression,
      'health_vas': healthVas,
      'entry_date': entryDate,
      'raw_data': rawData,
    });
    return http.post(uri, headers: _headers(patientCode), body: body);
  }

  Future<Map<String, dynamic>> getLarsData({
    required String patientCode,
    required String period, // "weekly", "monthly", or "yearly"
  }) async {
    final uri = Uri.parse('$_baseUrl/getLarsData?period=$period');
    try {
      final response = await http.get(uri, headers: _headers(patientCode));
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        // Return even if data array is empty - that's valid (no data yet)
        return decoded;
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      // Re-throw with more context, but don't fail if it's a network issue
      if (e.toString().contains('Exception')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getNextQuestionnaire({
    required String patientCode,
  }) async {
    final uri = Uri.parse('$_baseUrl/getNextQuestionnaire');
    try {
      final response = await http.get(uri, headers: _headers(patientCode));
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('Exception')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }
}
