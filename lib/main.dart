import 'package:flutter/material.dart';
import 'pages/accueil.dart'; // On importe notre page d'accueil
import 'pages/loading_page.dart';
import 'pages/login_page.dart';
import 'pages/registration_page.dart';
import 'pages/chat_page.dart';
import 'pages/ecran_alertes_predictions.dart';
import 'pages/ecran_historique_crises.dart';
import 'pages/ecran_profil.dart';
import 'pages/aide_choix.dart';
import 'services/auth_storage.dart';
// FONCTION PRINCIPALE - C'est ici que tout commence !
void main() async {
// Initialise SharedPreferences
  await AuthStorage.init();

  runApp(const MyApp()); // Lance l'application
}

// MyApp = Widget racine de toute l'application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // MaterialApp = Configure toute l'application
      
      title: 'RespirIA', // Nom de l'app
      
      debugShowCheckedModeBanner: false, // Enlève le bandeau "DEBUG" en haut
      
      theme: ThemeData(
        // Theme = Définit les couleurs et styles globaux de l'app
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto', // Police par défaut
        useMaterial3: true, // Utilise Material Design 3 (plus moderne)
      ),
      
      // Routes nommées pour accéder facilement aux nouvelles pages
      routes: {
        '/loading': (context) => const LoadingPage(),
        '/registration': (context) => const RegistrationPage(),
        '/chat': (context) => const ChatPage(),
        '/alerts': (context) => const EcranAlertesPredictions(),
        '/history': (context) => const EcranHistoriqueCrises(),
        '/profile': (context) => const EcranProfil(),
        '/aide': (context) => const AideChoixPage(),
        '/login': (context) => const LoginPage(),
      },

      // Démarrer sur la page de chargement (puis elle redirige vers l'inscription)
      home: const LoadingPage(),
    );
  }
}