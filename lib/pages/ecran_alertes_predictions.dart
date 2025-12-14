// Importe le package de base de Flutter et le widget de la barre de navigation.
import 'package:flutter/material.dart';
import 'env.dart';
import 'ecran_historique_crises.dart';
import 'ecran_profil.dart';
import '../state/app_state.dart';

// Définit un nouveau widget pour l'écran des alertes et des prédictions.
class EcranAlertesPredictions extends StatelessWidget {
  const EcranAlertesPredictions({super.key});

  // La méthode build est appelée par Flutter pour dessiner l'interface à l'écran.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          const Text(
            'Notifications intelligentes basées sur l\'IA',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          _buildCarteAlerte(
            context,
              niveauRisque: 'RISQUE TRÈS ÉLEVÉ',
              details: [
                'Crise possible dans 30-90 minutes',
                'SpO2 en baisse + Air très pollué',
              ],
              fiabilite: 89,
              timestamp: 'À l\'instant',
              couleur: Colors.red,
              icone: Icons.error_outline,
              bouton: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Center(child: Text('Prendre inhalateur préventif MAINTENANT', textAlign: TextAlign.center)),
              ),
            ),

            const SizedBox(height: 16),

            _buildCarteAlerte(
              context,
              niveauRisque: 'RISQUE ÉLEVÉ dans 2-4h',
              details: [
                'Pic pollution AQI 150 prévu 15h',
                'Restez à l\'intérieur et fermez fenêtres',
              ],
              fiabilite: 87,
              timestamp: 'Il y a 30 min',
              couleur: Colors.orange,
              icone: Icons.warning_amber_rounded,
              bouton: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade400),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Center(child: Text('Voir détails')),
              ),
            ),

            const SizedBox(height: 16),

            _buildCarteAlerte(
              context,
              niveauRisque: 'Rappel traitement',
              details: [
                'N\'oubliez pas votre corticoïde',
                'Dernière prise: il y a 12h',
              ],
              timestamp: 'Il y a 2h',
              couleur: Colors.amber,
              icone: Icons.timeline,
              bouton: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade400),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Center(child: Text('Voir détails')),
              ),
          ),

          const SizedBox(height: 24),

          _buildCarteIA(context),
          const SizedBox(height: 80), // Espace pour la barre de navigation
        ],
      ),
      ),
      
      // === BARRE DE NAVIGATION ===
      bottomNavigationBar: Builder(builder: (context) {
        final hide = AppState.hideCrises;
        final labels = hide
            ? ['Accueil', 'Environnement', 'Alertes', 'Profil']
            : ['Accueil', 'Environnement', 'Crises', 'Alertes', 'Profil'];
        final currentIndex = labels.indexOf('Alertes');
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey[600],
          currentIndex: currentIndex >= 0 ? currentIndex : 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          backgroundColor: Colors.white,
          elevation: 8,
          onTap: (index) {
            final label = labels[index];
            if (label == 'Accueil') {
              Navigator.popUntil(context, (route) => route.isFirst);
            } else if (label == 'Environnement') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EnvironnementPage()),
              );
            } else if (label == 'Crises') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EcranHistoriqueCrises()),
              );
            } else if (label == 'Alertes') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EcranAlertesPredictions()),
              );
            } else if (label == 'Profil') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EcranProfil()),
              );
            }
          },
          items: AppState.hideCrises
              ? const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    label: 'Accueil',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.insert_drive_file),
                    activeIcon: Icon(Icons.insert_drive_file),
                    label: 'Environnement',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.info_outline),
                    label: 'Alertes',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    label: 'Profil',
                  ),
                ]
              : const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    label: 'Accueil',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.insert_drive_file),
                    activeIcon: Icon(Icons.insert_drive_file),
                    label: 'Environnement',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.show_chart),
                    label: 'Crises',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.info_outline),
                    label: 'Alertes',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    label: 'Profil',
                  ),
                ],
        );
      }),
    );
  }

  // ... (toutes les autres fonctions _build... restent les mêmes)

  Color getCouleurFoncee(Color couleur) {
    final hsl = HSLColor.fromColor(couleur);
    final hslFonce = hsl.withLightness((hsl.lightness - 0.2).clamp(0.1, 1.0));
    return hslFonce.toColor();
  }

  Widget _buildCarteAlerte(
    BuildContext context,
    {
      required String niveauRisque,
      required List<String> details,
      required String timestamp,
      required Color couleur,
      required IconData icone,
      int? fiabilite,
      Widget? bouton,
    }
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: couleur, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, color: couleur, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  niveauRisque,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: couleur),
                ),
              ),
              Text(timestamp, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          ...details.map((detail) => Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(detail, style: TextStyle(color: getCouleurFoncee(couleur), fontWeight: FontWeight.w500)),
          )),

          if (fiabilite != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Fiabilité IA', style: TextStyle(color: Colors.black54, fontSize: 12)),
                      Text('$fiabilite%', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: fiabilite / 100.0,
                      backgroundColor: Colors.grey.shade300,
                      color: Colors.green,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),

          if (bouton != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: bouton,
            ),
        ],
      ),
    );
  }

  Widget _buildCarteIA(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.smart_toy_outlined, color: Colors.purple.shade800),
                ),
                const SizedBox(width: 12),
                Text(
                  'Intelligence Artificielle',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Les prédictions sont basées sur vos données vitales, l\'historique de vos crises, et les conditions environnementales en temps réel.',
              style: TextStyle(color: Colors.black54, fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildStatBox('87%', 'Précision\nmoyenne')),
                const SizedBox(width: 12),
                Expanded(child: _buildStatBox('30j', 'Données\nanalysées')),
                const SizedBox(width: 12),
                Expanded(child: _buildStatBox('12', 'Crises\névitées')),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(color: Colors.purple, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 12, height: 1.2),
          ),
        ],
      ),
    );
  }
}