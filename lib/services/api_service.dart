import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// Classe pour gérer les erreurs API
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException({required this.message, this.statusCode, this.originalError});

  @override
  String toString() => message;
}

class ApiService {
  // URL de base de ton backend Django
  static const String baseUrl = "https://respira-backend.onrender.com/";
  static const int timeoutSeconds = 10;

  // Méthode centralisée pour gérer les erreurs
  static String _handleError(dynamic error, int? statusCode, {String? responseBody}) {
    if (error is SocketException) {
      return "Erreur de connexion: Vérifiez votre internet";
    }

    switch (statusCode) {
      case 400:
        return "Données invalides. Vérifiez vos informations.";
      case 401:
        return "Authentification échouée. Email ou mot de passe incorrect.";
      case 404:
        return "Ressource non trouvée sur le serveur.";
      case 500:
        return "Erreur serveur (500). Contactez le support ou réessayez plus tard.";
      case null:
        return "Erreur de connexion: ${error.toString()}";
      default:
        return "Erreur ${statusCode}: ${error.toString()}";
    }
  }

  // Méthode utilitaire pour faire des requêtes
  static Future<Map<String, dynamic>> _makeRequest(
    Future<http.Response> Function() request,
    String operationName,
  ) async {
    try {
      final response = await request().timeout(
        const Duration(seconds: timeoutSeconds),
      );

      print("[$operationName] Status: ${response.statusCode}");
      print("[$operationName] Headers: ${response.headers}");
      print("[$operationName] Response Body: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': response.body.isNotEmpty ? json.decode(response.body) : {},
          'statusCode': response.statusCode,
        };
      } else {
        // En cas d'erreur, essayer de parser le JSON pour plus de détails
        String errorDetails = response.body;
        try {
          if (response.body.isNotEmpty && response.body.startsWith('{')) {
            final jsonError = json.decode(response.body);
            errorDetails = json.encode(jsonError);
          }
        } catch (e) {
          // Si ce n'est pas du JSON, garder le body tel quel
        }
        
        print("[$operationName] === ERREUR DÉTAILLÉE ===");
        print("[$operationName] Status Code: ${response.statusCode}");
        print("[$operationName] Error Details: $errorDetails");
        print("[$operationName] === FIN ERREUR ===");
        
        final errorMsg = _handleError(null, response.statusCode, responseBody: response.body);
        return {
          'success': false,
          'error': errorMsg,
          'statusCode': response.statusCode,
          'body': response.body,
        };
      }
    } on SocketException catch (e) {
      final errorMsg = _handleError(e, null);
      print("[$operationName] SocketException: $e");
      return {'success': false, 'error': errorMsg, 'statusCode': null};
    } on TimeoutException catch (e) {
      const errorMsg = "Délai d'attente dépassé. Serveur trop lent.";
      print("[$operationName] TimeoutException: $e");
      return {'success': false, 'error': errorMsg, 'statusCode': null};
    } catch (e) {
      final errorMsg = _handleError(e, null);
      print("[$operationName] Exception: $e");
      return {'success': false, 'error': errorMsg, 'statusCode': null};
    }
  }

  static Future<Map<String, dynamic>> getApiInfo() async {
    return _makeRequest(
      () => http.get(
        Uri.parse(baseUrl),
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
    String firstName = '',
    String lastName = '',
  }) async {
  final body = {
    "username": username.trim(),
    "email": email.trim(),
    "password": password,
    "password_confirm": passwordConfirm,
    "profile_type": profileType,
    "city": "Abidjan",
  };
    
    // Afficher chaque champ pour debug
    print("[registerUser] === Données envoyées ===");
    print("[registerUser] username: '$username'");
    print("[registerUser] email: '$email'");
    print("[registerUser] password: '${password.length} chars'");
    print("[registerUser] password_confirm: '${passwordConfirm.length} chars'");
    print("[registerUser] profile_type: '$profileType'");
    print("[registerUser] first_name: '$firstName'");
    print("[registerUser] last_name: '$lastName'");
    print("[registerUser] city: 'Abidjan'");
    print("[registerUser] Body JSON: ${json.encode(body)}");
    print("[registerUser] === Fin données ===");
    
    return _makeRequest(
      () => http.post(
        Uri.parse("${baseUrl}api/v1/users/auth/register/"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      ),
      'registerUser',
    );
  }
}
