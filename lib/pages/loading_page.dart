
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:APP3/pages/registration_page.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  double _loadingPercentage = 0;

  @override
  void initState() {
    super.initState();

    // Contrôleur pour l'animation de respiration
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Animation de mise à l'échelle (zoom in/out)
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Simulation du chargement
    Timer.periodic(const Duration(milliseconds: 40), (timer) {
      setState(() {
        _loadingPercentage += 1;
        if (_loadingPercentage >= 100) {
          timer.cancel();
          _navigateToNextPage();
        }
      });
    });
  }

  void _navigateToNextPage() {
    // Remplace la page de chargement par la page d'inscription
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const RegistrationPage()),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[800], // Fond bleu foncé
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animation du poumon
            ScaleTransition(
              scale: _scaleAnimation,
              child: Icon(
                Icons.air, // Icône de poumon
                color: Colors.white.withOpacity(0.9),
                size: 120,
              ),
            ),
            const SizedBox(height: 30),
            // Titre
            const Text(
              'RespirIA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 80),
            // Indicateur de chargement
            Text(
              'Chargement... ${_loadingPercentage.toInt()}%',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
