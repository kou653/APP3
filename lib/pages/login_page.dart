// Fichier : /lib/pages/login_page.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_storage.dart';
import 'registration_page.dart';
import 'asthmatique.dart';
import 'protection.dart';
import 'remission.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Effectue la connexion
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validation
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez remplir tous les champs';
      });
      return;
    }

    if (!email.contains('@')) {
      setState(() {
        _errorMessage = 'Veuillez entrer un email valide';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('[LoginPage] 🔐 Connexion en cours...');

      // Appeler l'API de connexion
      final result = await ApiService.loginUser(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        print('[LoginPage] ✅ Réponse API reçue');

        final data = result['data'] as Map<String, dynamic>? ?? {};
        final accessToken = data['access'];
        final refreshToken = data['refresh'];

        if (accessToken == null || accessToken.isEmpty) {
          setState(() {
            _errorMessage = 'Erreur: Token non reçu';
            _isLoading = false;
          });
          return;
        }

        print('[LoginPage] 🔐 Tokens reçus');

        // Récupérer les infos utilisateur
        print('[LoginPage] 👤 Récupération du profil...');
        final profileResult = await ApiService.getUserProfile(token: accessToken);

        if (!mounted) return;

        if (profileResult['success'] != true) {
          setState(() {
            _errorMessage = 'Erreur lors de la récupération du profil';
            _isLoading = false;
          });
          return;
        }

        // Extraire les infos utilisateur
        final profileData = profileResult['data'] as Map<String, dynamic>? ?? {};
        final username = profileData['username'] ?? 'Utilisateur';
        final userEmail = profileData['email'] ?? email;

        print('[LoginPage] 👤 Utilisateur: $username');

        // Sauvegarder les données d'authentification
        await AuthStorage.saveAuthData(
          accessToken: accessToken,
          refreshToken: refreshToken ?? '',
          userName: username,
          userEmail: userEmail,
        );

        print('[LoginPage] ✅ Données sauvegardées dans AuthStorage');
        AuthStorage.printStatus();

        // Extraire le type de profil
        String profileType = 'ASTHMATIC';
        try {
          final profile = profileData['profile'] as Map<String, dynamic>?;
          if (profile != null) {
            final type = profile['profile_type']?.toString().toUpperCase();
            if (type != null && type.isNotEmpty) {
              profileType = type;
            }
          }
        } catch (e) {
          print('[LoginPage] ⚠️ Erreur lors du parsing du profil: $e');
        }

        print('[LoginPage] 👤 Type de profil: $profileType');

        // Rediriger selon le type de profil
        if (!mounted) return;

        switch (profileType) {
          case 'ASTHMATIC':
            print('[LoginPage] ➡️ Redirection vers AsthmatiquePage');
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const AsthmatiquePage()),
              (route) => false,
            );
            break;
          case 'PREVENTION':
            print('[LoginPage] ➡️ Redirection vers ProtectionPage');
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const ProtectionPage()),
              (route) => false,
            );
            break;
          case 'REMISSION':
            print('[LoginPage] ➡️ Redirection vers RemissionPage');
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const RemissionPage()),
              (route) => false,
            );
            break;
          default:
            print('[LoginPage] ⚠️ Type de profil inconnu, redirection vers Asthmatique');
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const AsthmatiquePage()),
              (route) => false,
            );
        }
      } else {
        print('[LoginPage] ❌ Erreur API: ${result['error']}');
        setState(() {
          _errorMessage = result['error'] ?? 'Erreur de connexion';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('[LoginPage] 💥 Exception: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Logo et titre
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade400,
                              Colors.blue.shade600,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'RespirIA',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gestion intelligente de l\'asthme',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // Titre
                Text(
                  'Connexion',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 8),
                Text(
                  'Connectez-vous à votre compte',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 32),

                // Message d'erreur
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Champ Email
                Text(
                  'Email',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Entrez votre email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Champ Mot de passe
                Text(
                  'Mot de passe',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  enabled: !_isLoading,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Entrez votre mot de passe',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Bouton Connexion
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 4,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Se connecter',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Lien inscription
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Pas de compte ? ',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: 'S\'inscrire',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RegistrationPage(),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}