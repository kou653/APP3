// Fichier : /lib/services/crisis_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/crisis.dart';

/// Service pour gérer l'historique des crises
class CrisisService {
  static const String baseUrl = "https://respira-backend.onrender.com/api/v1";
  static const int timeoutSeconds = 30;

  /// Récupère toutes les crises (paginées)
  static Future<Map<String, dynamic>> getCrises({
    required String token,
    int page = 1,
    int pageSize = 20,
    String? sortBy = '-start_time', // Tri par défaut (plus récent d'abord)
  }) async {
    try {
      print('[CrisisService] 📋 getCrises - Page $page');

      final uri = Uri.parse('$baseUrl/crises/').replace(
        queryParameters: {
          'page': page.toString(),
          'page_size': pageSize.toString(),
          if (sortBy != null) 'ordering': sortBy,
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: timeoutSeconds));

      print('[CrisisService] Status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('[CrisisService] ✅ getCrises - Succès');

        final data = json.decode(response.body);
        final List<dynamic> crisesData = data['results'] ?? data['crises'] ?? [];
        final crises = crisesData.map((c) => Crisis.fromJson(c)).toList();

        return {
          'success': true,
          'crises': crises,
          'count': data['count'] ?? crisesData.length,
          'next': data['next'],
          'previous': data['previous'],
        };
      } else {
        print('[CrisisService] ❌ getCrises - Erreur ${response.statusCode}');
        return {
          'success': false,
          'error': 'Erreur ${response.statusCode}',
          'crises': [],
        };
      }
    } on TimeoutException {
      print('[CrisisService] ⏱️ getCrises - Timeout');
      return {
        'success': false,
        'error': 'Délai d\'attente dépassé',
        'crises': [],
      };
    } on SocketException catch (e) {
      print('[CrisisService] 🌐 getCrises - Erreur réseau: $e');
      return {
        'success': false,
        'error': 'Erreur de connexion',
        'crises': [],
      };
    } catch (e) {
      print('[CrisisService] 💥 getCrises - Exception: $e');
      return {
        'success': false,
        'error': 'Erreur: $e',
        'crises': [],
      };
    }
  }

  /// Récupère une crise spécifique
  static Future<Map<String, dynamic>> getCrisisById({
    required String token,
    required int crisisId,
  }) async {
    try {
      print('[CrisisService] 🔍 getCrisisById - ID: $crisisId');

      final response = await http.get(
        Uri.parse('$baseUrl/crises/$crisisId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('[CrisisService] ✅ getCrisisById - Succès');
        final crisis = Crisis.fromJson(json.decode(response.body));
        return {
          'success': true,
          'crisis': crisis,
        };
      } else {
        print('[CrisisService] ❌ getCrisisById - Erreur ${response.statusCode}');
        return {
          'success': false,
          'error': 'Crise non trouvée',
        };
      }
    } catch (e) {
      print('[CrisisService] 💥 getCrisisById - Exception: $e');
      return {
        'success': false,
        'error': 'Erreur: $e',
      };
    }
  }

  /// Crée une nouvelle crise
  static Future<Map<String, dynamic>> createCrisis({
    required String token,
    required DateTime startTime,
    DateTime? endTime,
    int? durationMinutes,
    int? minSpo2,
    int? maxHeartRate,
    required String triggerFactor,
    required String severity, // 'light', 'moderate', 'severe'
    String? notes,
    bool? treatedWithInhaler,
    String? inhalerType,
  }) async {
    try {
      print('[CrisisService] ➕ createCrisis');

      final body = <String, dynamic>{
        'start_time': startTime.toIso8601String(),
        'trigger_factor': triggerFactor,
        'severity': severity,
      };

      if (endTime != null) body['end_time'] = endTime.toIso8601String();
      if (durationMinutes != null) body['duration_minutes'] = durationMinutes;
      if (minSpo2 != null) body['min_spo2'] = minSpo2;
      if (maxHeartRate != null) body['max_heart_rate'] = maxHeartRate;
      if (notes != null) body['notes'] = notes;
      if (treatedWithInhaler != null) body['treated_with_inhaler'] = treatedWithInhaler;
      if (inhalerType != null) body['inhaler_type'] = inhalerType;

      final response = await http.post(
        Uri.parse('$baseUrl/crises/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('[CrisisService] ✅ createCrisis - Succès');
        final crisis = Crisis.fromJson(json.decode(response.body));
        return {
          'success': true,
          'crisis': crisis,
        };
      } else {
        print('[CrisisService] ❌ createCrisis - Erreur ${response.statusCode}');
        return {
          'success': false,
          'error': 'Impossible de créer la crise',
        };
      }
    } catch (e) {
      print('[CrisisService] 💥 createCrisis - Exception: $e');
      return {
        'success': false,
        'error': 'Erreur: $e',
      };
    }
  }

  /// Met à jour une crise
  static Future<Map<String, dynamic>> updateCrisis({
    required String token,
    required int crisisId,
    DateTime? endTime,
    int? durationMinutes,
    int? minSpo2,
    int? maxHeartRate,
    String? triggerFactor,
    String? severity,
    String? notes,
    bool? treatedWithInhaler,
    String? inhalerType,
  }) async {
    try {
      print('[CrisisService] ✏️ updateCrisis - ID: $crisisId');

      final body = <String, dynamic>{};

      if (endTime != null) body['end_time'] = endTime.toIso8601String();
      if (durationMinutes != null) body['duration_minutes'] = durationMinutes;
      if (minSpo2 != null) body['min_spo2'] = minSpo2;
      if (maxHeartRate != null) body['max_heart_rate'] = maxHeartRate;
      if (triggerFactor != null) body['trigger_factor'] = triggerFactor;
      if (severity != null) body['severity'] = severity;
      if (notes != null) body['notes'] = notes;
      if (treatedWithInhaler != null) body['treated_with_inhaler'] = treatedWithInhaler;
      if (inhalerType != null) body['inhaler_type'] = inhalerType;

      final response = await http.patch(
        Uri.parse('$baseUrl/crises/$crisisId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('[CrisisService] ✅ updateCrisis - Succès');
        final crisis = Crisis.fromJson(json.decode(response.body));
        return {
          'success': true,
          'crisis': crisis,
        };
      } else {
        print('[CrisisService] ❌ updateCrisis - Erreur ${response.statusCode}');
        return {
          'success': false,
          'error': 'Impossible de mettre à jour la crise',
        };
      }
    } catch (e) {
      print('[CrisisService] 💥 updateCrisis - Exception: $e');
      return {
        'success': false,
        'error': 'Erreur: $e',
      };
    }
  }

  /// Supprime une crise
  static Future<Map<String, dynamic>> deleteCrisis({
    required String token,
    required int crisisId,
  }) async {
    try {
      print('[CrisisService] 🗑️ deleteCrisis - ID: $crisisId');

      final response = await http.delete(
        Uri.parse('$baseUrl/crises/$crisisId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('[CrisisService] ✅ deleteCrisis - Succès');
        return {'success': true};
      } else {
        print('[CrisisService] ❌ deleteCrisis - Erreur ${response.statusCode}');
        return {
          'success': false,
          'error': 'Impossible de supprimer la crise',
        };
      }
    } catch (e) {
      print('[CrisisService] 💥 deleteCrisis - Exception: $e');
      return {
        'success': false,
        'error': 'Erreur: $e',
      };
    }
  }

  /// Récupère les statistiques des crises
  static Future<Map<String, dynamic>> getCrisisStats({
    required String token,
  }) async {
    try {
      print('[CrisisService] 📊 getCrisisStats');

      final response = await http.get(
        Uri.parse('$baseUrl/crises/stats/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('[CrisisService] ✅ getCrisisStats - Succès');

        final data = json.decode(response.body);
        final stats = CrisisStats.fromJson(data);

        return {
          'success': true,
          'stats': stats,
        };
      } else {
        print('[CrisisService] ❌ getCrisisStats - Erreur ${response.statusCode}');
        return {
          'success': false,
          'error': 'Erreur ${response.statusCode}',
        };
      }
    } catch (e) {
      print('[CrisisService] 💥 getCrisisStats - Exception: $e');
      return {
        'success': false,
        'error': 'Erreur: $e',
      };
    }
  }

  /// Récupère les patterns détectés
  static Future<Map<String, dynamic>> getPatterns({
    required String token,
  }) async {
    try {
      print('[CrisisService] 🎯 getPatterns');

      final response = await http.get(
        Uri.parse('$baseUrl/crises/patterns/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('[CrisisService] ✅ getPatterns - Succès');

        final data = json.decode(response.body);
        final List<dynamic> patternsData = data['patterns'] ?? data['results'] ?? [];
        final patterns = patternsData
            .map((p) => CrisisPattern.fromJson(p))
            .toList();

        return {
          'success': true,
          'patterns': patterns,
        };
      } else {
        print('[CrisisService] ❌ getPatterns - Erreur ${response.statusCode}');
        return {
          'success': false,
          'error': 'Erreur ${response.statusCode}',
          'patterns': [],
        };
      }
    } catch (e) {
      print('[CrisisService] 💥 getPatterns - Exception: $e');
      return {
        'success': false,
        'error': 'Erreur: $e',
        'patterns': [],
      };
    }
  }
}