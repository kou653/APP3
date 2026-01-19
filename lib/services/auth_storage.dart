import 'package:shared_preferences/shared_preferences.dart';

/// Classe de gestion de l'authentification et du stockage local
class AuthStorage {
  // Keys pour les tokens
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  // Keys pour les données utilisateur
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userIdKey = 'user_id';

  // Instance statique de SharedPreferences
  static late SharedPreferences _prefs;

  /// Initialise AuthStorage avec SharedPreferences
  /// À appeler impérativement dans main() avant runApp()
  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      print('[AuthStorage] ✅ Initialisé avec succès');
    } catch (e) {
      print('[AuthStorage] ❌ Erreur lors de l\'initialisation: $e');
      rethrow;
    }
  }

  // ============ GESTION DES TOKENS ============

  /// Sauvegarde les tokens d'accès et de rafraîchissement
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await _prefs.setString(_accessTokenKey, accessToken);
      await _prefs.setString(_refreshTokenKey, refreshToken);
      print('[AuthStorage] ✅ Tokens sauvegardés');
    } catch (e) {
      print('[AuthStorage] ❌ Erreur lors de la sauvegarde des tokens: $e');
      rethrow;
    }
  }

  /// Récupère le token d'accès JWT
  static String? getAccessToken() {
    try {
      return _prefs.getString(_accessTokenKey);
    } catch (e) {
      print('[AuthStorage] ❌ Erreur lors de la récupération du token: $e');
      return null;
    }
  }

  /// Récupère le refresh token
  static String? getRefreshToken() {
    try {
      return _prefs.getString(_refreshTokenKey);
    } catch (e) {
      print('[AuthStorage] ❌ Erreur lors de la récupération du refresh token: $e');
      return null;
    }
  }

  // ============ GESTION DES DONNÉES UTILISATEUR ============

  /// Sauvegarde les données complètes après une connexion réussie
  /// À appeler dans login_page.dart après ApiService.loginUser()
  static Future<void> saveAuthData({
    required String accessToken,
    required String refreshToken,
    required String userName,
    required String userEmail,
    String? userId,
  }) async {
    try {
      await Future.wait([
        _prefs.setString(_accessTokenKey, accessToken),
        _prefs.setString(_refreshTokenKey, refreshToken),
        _prefs.setString(_userNameKey, userName),
        _prefs.setString(_userEmailKey, userEmail),
        if (userId != null) _prefs.setString(_userIdKey, userId),
      ]);
      print('[AuthStorage] ✅ Données d\'authentification sauvegardées');
    } catch (e) {
      print('[AuthStorage] ❌ Erreur lors de la sauvegarde des données: $e');
      rethrow;
    }
  }

  /// Récupère le nom de l'utilisateur
  static String? getUserName() {
    try {
      return _prefs.getString(_userNameKey);
    } catch (e) {
      print('[AuthStorage] ❌ Erreur lors de la récupération du nom: $e');
      return null;
    }
  }

  /// Récupère l'email de l'utilisateur
  static String? getUserEmail() {
    try {
      return _prefs.getString(_userEmailKey);
    } catch (e) {
      print('[AuthStorage] ❌ Erreur lors de la récupération de l\'email: $e');
      return null;
    }
  }

  /// Récupère l'ID de l'utilisateur
  static String? getUserId() {
    try {
      return _prefs.getString(_userIdKey);
    } catch (e) {
      print('[AuthStorage] ❌ Erreur lors de la récupération de l\'ID: $e');
      return null;
    }
  }

  // ============ VÉRIFICATIONS ============

  /// Vérifie si l'utilisateur est connecté (token présent et valide)
  static bool isLoggedIn() {
    try {
      final token = _prefs.getString(_accessTokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      print('[AuthStorage] ❌ Erreur lors de la vérification: $e');
      return false;
    }
  }

  /// Vérifie si les données utilisateur existent
  static bool hasUserData() {
    try {
      return getUserName() != null && getUserEmail() != null;
    } catch (e) {
      print('[AuthStorage] ❌ Erreur lors de la vérification des données: $e');
      return false;
    }
  }

  // ============ DÉCONNEXION ============

  /// Efface tous les tokens et données utilisateur
  /// À appeler lors de la déconnexion
  static Future<void> clearTokens() async {
    try {
      await _prefs.clear();
      print('[AuthStorage] ✅ Tokens et données effacés');
    } catch (e) {
      print('[AuthStorage] ❌ Erreur lors de l\'effacement: $e');
      rethrow;
    }
  }

  /// Alias pour clearTokens (pour la clarté)
  static Future<void> logout() async {
    await clearTokens();
  }

  // ============ UTILITAIRES ============

  /// Récupère tous les tokens (utile pour debug)
  static Map<String, String?> getAllTokens() {
    return {
      'access': getAccessToken(),
      'refresh': getRefreshToken(),
    };
  }

  /// Affiche le statut complet (pour debug)
  static void printStatus() {
    print('');
    print('╔════════════════════════════════════╗');
    print('║     [AuthStorage] STATUT ACTUEL    ║');
    print('╚════════════════════════════════════╝');
    print('📝 Connecté: ${isLoggedIn()}');
    print('👤 Utilisateur: ${getUserName() ?? "N/A"}');
    print('📧 Email: ${getUserEmail() ?? "N/A"}');
    print('🆔 ID: ${getUserId() ?? "N/A"}');
    print('🔐 Token: ${getAccessToken() != null ? "✅ Présent" : "❌ Absent"}');
    print('');
  }
}