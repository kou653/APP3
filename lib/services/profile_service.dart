// Fichier : /lib/services/profile_service.dart

import 'api_service.dart';
import 'auth_storage.dart';
import '../models/user_profile.dart';

class ProfileService {
  /// Récupère le profil complet de l'utilisateur connecté
  static Future<User?> getCurrentUserProfile() async {
    final token = AuthStorage.accessToken;
    
    if (token == null) return null;

    try {
      final result = await ApiService.getUserProfile(token: token);
      if (result['success'] == true) {
        return User.fromJson(result['data']);
      }
      return null;
    } catch (e) {
      print('[ProfileService] ❌ Erreur: $e');
      return null;
    }
  }

  /// Met à jour le profil utilisateur
  static Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    final token = AuthStorage.accessToken;

    if (token == null) return false;

    try {
      final result = await ApiService.updateUserProfile(
        token: token,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );
      return result['success'] == true;
    } catch (e) {
      print('[ProfileService] ❌ Erreur: $e');
      return false;
    }
  }

  /// Met à jour les préférences du profil
  static Future<bool> updateProfileSettings({
    String? city,
    bool? alertsEnabled,
    int? daysWithoutSymptoms,
  }) async {
    // Cette méthode nécessiterait un endpoint API correspondant
    // Pour l'instant, utilisez directement ApiService
    return false;
  }
}