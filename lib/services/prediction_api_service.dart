// Fichier : /lib/services/prediction_api_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class PredictionApiService {
  static const String baseUrl = 'https://ml-respir-ai.onrender.com/api/v1';
  static const int timeoutSeconds = 45; // Increased timeout for ML API

  static Future<Map<String, dynamic>> _makeRequest(
    Future<http.Response> Function() request,
    String operationName,
  ) async {
    try {
      print('[PredictionApiService] 🔵 $operationName - Requête envoyée');
      final response = await request().timeout(const Duration(seconds: timeoutSeconds));
      print('[PredictionApiService] Status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('[PredictionApiService] ✅ $operationName - Succès');
        if (response.body.isEmpty) {
          return {'success': true, 'data': {}};
        }
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        final errorBody = response.body;
        print('[PredictionApiService] ❌ $operationName - Erreur ${response.statusCode}: $errorBody');
        return {
          'success': false,
          'error': 'Erreur API (${response.statusCode})',
          'details': errorBody,
        };
      }
    } on TimeoutException {
      print('[PredictionApiService] ⏱️ $operationName - Timeout');
      return {
        'success': false,
        'error': "Délai d'attente dépassé. Le serveur de prédiction est peut-être surchargé.",
      };
    } on SocketException catch (e) {
      print('[PredictionApiService] 🌐 $operationName - Erreur réseau: $e');
      return {
        'success': false,
        'error': 'Erreur de connexion au service de prédiction.',
      };
    } catch (e) {
      print('[PredictionApiService] 💥 $operationName - Exception: $e');
      return {
        'success': false,
        'error': 'Une erreur inattendue est survenue: $e',
      };
    }
  }

  Future<Map<String, dynamic>> predict({
    required String userId,
    required int profileId,
    String? location,
    bool? medicationTaken,
    Map<String, dynamic>? sensorData,
  }) async {
    print('[PredictionApiService] 🚀 Appel de la prédiction');
    return _makeRequest(
      () => http.post(
        Uri.parse('$baseUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'profile_id': profileId,
          'location': location ?? 'Abidjan', // Default value
          'medication_taken': medicationTaken ?? true, // Default value
          if (sensorData != null) 'sensor_data': sensorData,
        }),
      ),
      'predict',
    );
  }

  Future<Map<String, dynamic>> getDashboard(String userId, String? location) async {
    print('[PredictionApiService] 📊 Appel du dashboard');
    final uri = Uri.parse('$baseUrl/dashboard').replace(queryParameters: {
      'user_id': userId,
      if (location != null) 'location': location,
    });

    return _makeRequest(
      () => http.get(uri),
      'getDashboard',
    );
  }
}