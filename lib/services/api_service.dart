// Fichier : /lib/services/api_service.dart (VERSION AMÉLIORÉE)
import 'api_config.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// ============ SERVICE API COMPLET ============

class ApiService {
  // URLs de base
  static const String baseUrl = "https://respira-backend.onrender.com/api/v1";
  static const String chatbotBaseUrl = "https://respira-backend.onrender.com/api/v1/chatbot/";
   
  // Timeout
  static const int timeoutSeconds = 30;

  // ============ GESTION DES ERREURS ============

  static String _handleError(dynamic error, int? statusCode) {
    if (error is SocketException) {
      return "❌ Erreur de connexion: Vérifiez votre internet";
    }

    switch (statusCode) {
      case 400:
        return "❌ Requête invalide. Vérifiez vos données.";
      case 401:
        return "❌ Non authentifié. Veuillez vous reconnecter.";
      case 403:
        return "❌ Accès refusé. Votre session a expiré.";
      case 404:
        return "❌ Ressource non trouvée.";
      case 500:
        return "❌ Erreur serveur. Réessayez plus tard.";
      case null:
        return "❌ Erreur de connexion: ${error.toString()}";
      default:
        return "❌ Erreur $statusCode";
    }
  }

  static Future<Map<String, dynamic>> _makeRequest(
    Future<http.Response> Function() request,
    String operationName,
    
  ) async {
    try {
      print('[ApiService] 🔵 $operationName - Requête envoyée');

      final response = await request().timeout(
        const Duration(seconds: timeoutSeconds),
      );

      print('[ApiService] Status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('[ApiService] ✅ $operationName - Succès');
        return {
          'success': true,
          'data': response.body.isNotEmpty ? json.decode(response.body) : {},
          'statusCode': response.statusCode,
        };
      } else {
        String errorMessage = response.body;
        try {
          if (response.body.isNotEmpty && response.body.startsWith('{')) {
            final jsonError = json.decode(response.body);
            errorMessage = jsonError['detail'] ??
                jsonError['error'] ??
                jsonError['message'] ??
                response.body;
          }
        } catch (e) {
          // Si ce n'est pas du JSON, garder tel quel
        }

        print('[ApiService] ❌ $operationName - Erreur ${response.statusCode}');
        print('[ApiService] Message: $errorMessage');

        final errorMsg = _handleError(null, response.statusCode);
        return {
          'success': false,
          'error': errorMsg,
          'details': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } on TimeoutException {
      print('[ApiService] ⏱️ $operationName - Timeout');
      return {
        'success': false,
        'error': "⏱️ Délai d'attente dépassé. Le serveur est lent.",
        'statusCode': null,
      };
    } on SocketException catch (e) {
      print('[ApiService] 🌐 $operationName - Erreur de connexion: $e');
      final errorMsg = _handleError(e, null);
      return {
        'success': false,
        'error': errorMsg,
        'statusCode': null,
      };
    } catch (e) {
      print('[ApiService] 💥 $operationName - Exception: $e');
      final errorMsg = _handleError(e, null);
      return {
        'success': false,
        'error': errorMsg,
        'statusCode': null,
      };
    }
  }

  // ============ AUTHENTIFICATION ============

  static Future<Map<String, dynamic>> getApiInfo() async {
    return _makeRequest(
      () => http.get(
        Uri.parse("https://respira-backend.onrender.com/"),
        headers: {"Content-Type": "application/json"},
      ),
      'getApiInfo',
    );
  }

  static Future<Map<String, dynamic>> registerUser({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
    required String profileType,
    required String firstName,
    required String lastName,
  }) async {
    final body = {
      "username": username.trim(),
      "email": email.trim(),
      "password": password.trim(),
      "password_confirm": passwordConfirm.trim(),
      "profile_type": profileType,
      "first_name": firstName.trim(),
      "last_name": lastName.trim(),
    };

    print('[ApiService] 📝 registerUser - Envoi données');

    return _makeRequest(
      () => http.post(
        Uri.parse("$baseUrl/users/auth/register/"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      ),
      'registerUser',
    );
  }

  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final body = {
      "email": email.trim(),
      "password": password.trim(),
    };

    print('[ApiService] 🔐 loginUser - Connexion en cours');

    return _makeRequest(
      () => http.post(
        Uri.parse("$baseUrl/users/auth/login/"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      ),
      'loginUser',
    );
  }

  // ============ PROFIL UTILISATEUR ============

  /// Récupère le profil complet de l'utilisateur
  static Future<Map<String, dynamic>> getUserProfile({
    required String token,
  }) async {
    print('[ApiService] 👤 getUserProfile - Récupération du profil');

    return _makeRequest(
      () => http.get(
        Uri.parse("$baseUrl/users/me/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ),
      'getUserProfile',
    );
  }

  /// Met à jour le profil utilisateur
  static Future<Map<String, dynamic>> updateUserProfile({
    required String token,
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    final body = <String, dynamic>{};
    if (firstName != null) body['first_name'] = firstName;
    if (lastName != null) body['last_name'] = lastName;
    if (phone != null) body['phone'] = phone;

    print('[ApiService] ✏️ updateUserProfile - Mise à jour');

    return _makeRequest(
      () => http.patch(
        Uri.parse("$baseUrl/users/me/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(body),
      ),
      'updateUserProfile',
    );
  }

  // ============ DONNÉES CAPTEURS ============

  /// Récupère les dernières données capteurs
  static Future<Map<String, dynamic>> getLatestSensorData({
    required String token,
  }) async {
    print('[ApiService] 📊 getLatestSensorData - Récupération');

    return _makeRequest(
      () => http.get(
        Uri.parse("$baseUrl/sensors/data/latest/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ),
      'getLatestSensorData',
    );
  }

  /// Récupère le score de risque actuel
  static Future<Map<String, dynamic>> getRiskScore({
    required String token,
  }) async {
    print('[ApiService] ⚠️ getRiskScore - Récupération du score');

    return _makeRequest(
      () => http.get(
        Uri.parse("$baseUrl/sensors/data/risk_score/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ),
      'getRiskScore',
    );
  }

  /// Récupère l'historique des données capteurs (paginé)
  static Future<Map<String, dynamic>> getSensorDataHistory({
    required String token,
    int page = 1,
    int pageSize = 20,
  }) async {
    print('[ApiService] 📜 getSensorDataHistory - Page $page');

    return _makeRequest(
      () => http.get(
        Uri.parse("$baseUrl/sensors/data/?page=$page&page_size=$pageSize"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ),
      'getSensorDataHistory',
    );
  }

  /// Récupère les statistiques sur une période
  static Future<Map<String, dynamic>> getSensorStats({
    required String token,
    String period = '24h', // '24h', '7d', '30d'
  }) async {
    print('[ApiService] 📈 getSensorStats - Période: $period');

    return _makeRequest(
      () => http.get(
        Uri.parse("$baseUrl/sensors/data/stats/?period=$period"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ),
      'getSensorStats',
    );
  }

  /// Envoie des données capteurs
  static Future<Map<String, dynamic>> sendSensorData({
    required String token,
    required DateTime timestamp,
    int? spo2,
    int? heartRate,
    int? respiratoryRate,
    double? temperature,
    String? activityLevel,
    int? steps,
    int? riskScore,
  }) async {
    final body = <String, dynamic>{
      'timestamp': timestamp.toIso8601String(),
    };

    if (spo2 != null) body['spo2'] = spo2;
    if (heartRate != null) body['heart_rate'] = heartRate;
    if (respiratoryRate != null) body['respiratory_rate'] = respiratoryRate;
    if (temperature != null) body['temperature'] = temperature;
    if (activityLevel != null) body['activity_level'] = activityLevel;
    if (steps != null) body['steps'] = steps;
    if (riskScore != null) body['risk_score'] = riskScore;

    print('[ApiService] 📤 sendSensorData - Envoi des données');

    return _makeRequest(
      () => http.post(
        Uri.parse("$baseUrl/sensors/data/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(body),
      ),
      'sendSensorData',
    );
  }

  // ============ ENVIRONNEMENT ============

  /// Récupère la qualité de l'air actuelle
  static Future<Map<String, dynamic>> getAirQuality({
    required String token,
    String? city,
  }) async {
    print('[ApiService] 🌫️ getAirQuality - Ville: ${city ?? "profil"}');

    final uri = city != null
        ? Uri.parse("$baseUrl/environment/air-quality/?city=$city")
        : Uri.parse("$baseUrl/environment/air-quality/");

    return _makeRequest(
      () => http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ),
      'getAirQuality',
    );
  }

  /// Récupère la météo actuelle
  static Future<Map<String, dynamic>> getWeather({
    required String token,
    String? city,
  }) async {
    print('[ApiService] ☁️ getWeather - Ville: ${city ?? "profil"}');

    final uri = city != null
        ? Uri.parse("$baseUrl/environment/weather/?city=$city")
        : Uri.parse("$baseUrl/environment/weather/");

    return _makeRequest(
      () => http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ),
      'getWeather',
    );
  }


  // ============ CHATBOT ============

  static Future<Map<String, dynamic>> sendChatbotMessage({
    required String message,
    required String token,
  }) async {
    if (message.trim().isEmpty) {
      return {
        'success': false,
        'error': 'Le message ne peut pas être vide',
        'statusCode': 400,
      };
    }

    final body = {
      "message": message.trim(),
    };

    print('[ApiService] 💬 sendChatbotMessage - Envoi: "$message"');

    return _makeRequest(
      () => http.post(
        Uri.parse("${chatbotBaseUrl}chat/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(body),
      ),
      'sendChatbotMessage',
    );
  }

  static Future<Map<String, dynamic>> getChatbotHistory({
    required String token,
  }) async {
    print('[ApiService] 📜 getChatbotHistory - Récupération de l\'historique');

    return _makeRequest(
      () => http.get(
        Uri.parse("${chatbotBaseUrl}history/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ),
      'getChatbotHistory',
    );
  }
}