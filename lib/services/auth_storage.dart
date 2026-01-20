// Fichier : /lib/services/auth_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

/// Service pour stocker et récupérer le token JWT et les infos utilisateur
class AuthStorage {
  static SharedPreferences? _prefs;

  // Clés de stockage
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUsername = 'username';
  static const String _keyProfileType = 'profile_type';
  static const String _keyCity = 'city';

  /// Initialiser SharedPreferences (à appeler dans main())
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    print('[AuthStorage] ✅ Initialized');
  }

  /// Sauvegarder les tokens après connexion/inscription
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _prefs?.setString(_keyAccessToken, accessToken);
    await _prefs?.setString(_keyRefreshToken, refreshToken);
    print('[AuthStorage] 💾 Tokens saved');
  }

  /// Sauvegarder les informations utilisateur
  static Future<void> saveUserInfo({
    required int userId,
    required String email,
    required String username,
    String? profileType,
    String? city,
  }) async {
    await _prefs?.setInt(_keyUserId, userId);
    await _prefs?.setString(_keyUserEmail, email);
    await _prefs?.setString(_keyUsername, username);
    if (profileType != null) {
      await _prefs?.setString(_keyProfileType, profileType);
    }
    if (city != null) {
      await _prefs?.setString(_keyCity, city);
    }
    print('[AuthStorage] 👤 User info saved: $username');
  }

  /// Récupérer le token d'accès
  static String? get accessToken => _prefs?.getString(_keyAccessToken);

  /// Récupérer le token de rafraîchissement
  static String? get refreshToken => _prefs?.getString(_keyRefreshToken);

  /// Récupérer l'ID utilisateur
  static int? get userId => _prefs?.getInt(_keyUserId);

  /// Récupérer l'email utilisateur
  static String? get userEmail => _prefs?.getString(_keyUserEmail);

  /// Récupérer le username
  static String? get username => _prefs?.getString(_keyUsername);

  /// Récupérer le type de profil
  static String? get profileType => _prefs?.getString(_keyProfileType);

  /// Récupérer la ville
  static String? get city => _prefs?.getString(_keyCity);

  /// Vérifier si l'utilisateur est connecté
  static bool get isLoggedIn => accessToken != null && accessToken!.isNotEmpty;

  /// Déconnexion (efface toutes les données)
  static Future<void> logout() async {
    await _prefs?.clear();
    print('[AuthStorage] 🚪 User logged out');
  }

  /// Mettre à jour uniquement le token d'accès (après refresh)
  static Future<void> updateAccessToken(String newAccessToken) async {
    await _prefs?.setString(_keyAccessToken, newAccessToken);
    print('[AuthStorage] 🔄 Access token refreshed');
  }
}