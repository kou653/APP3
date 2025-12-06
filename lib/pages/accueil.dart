// ignore: file_names
import 'package:flutter/material.dart';
import 'asthmatique.dart'; // Import de la page asthmatique
import 'protection.dart'; // Import de la page protection
import 'remission.dart'; // Import de la page rémission

// StatefulWidget = un widget qui peut changer d'état
class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  // Variable pour stocker l'option sélectionnée
  String? selectedOption; // null = aucune sélection

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          
          child: Column(
            children: [
              // Header centré verticalement
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5B7EFF), Color(0xFF9B5BFF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withAlpha((0.3 * 255).round()),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.monitor_heart, color: Colors.white, size: 50),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Bienvenue sur RespirIA',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Votre assistant respiratoire intelligent',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Quelle est votre situation respiratoire ?',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black45),
                      ),
                    ],
                  ),
                ),
              ),

              // Options et boutons dans une zone scrollable
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      
                      // Option 1: Asthmatique (cliquable)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedOption = 'asthmatique';
                          });
                        },
                        child: _buildOptionCard(
                          icon: Icons.monitor_heart_outlined,
                          iconColor: Colors.red,
                          iconBgColor: Colors.red.shade50,
                          title: 'JE SUIS ASTHMATIQUE',
                          subtitle: 'Diagnostic médical confirmé',
                          badge: 'Surveillance 24/7 activée',
                          badgeColor: Colors.red.shade50,
                          badgeTextColor: Colors.red,
                          footer: 'Nécessite bracelet connecté',
                          isSelected: selectedOption == 'asthmatique',
                          borderColor: Colors.red, // Bordure rouge
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Option 2: Protection (cliquable)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedOption = 'protection';
                          });
                        },
                        child: _buildOptionCard(
                          icon: Icons.shield_outlined,
                          iconColor: Colors.green,
                          iconBgColor: Colors.green.shade50,
                          title: 'JE VEUX ME PROTÉGER',
                          subtitle: 'Aucun diagnostic, prévention',
                          badge: 'Surveillance légère',
                          badgeColor: Colors.green.shade50,
                          badgeTextColor: Colors.green,
                          footer: 'Bracelet optionnel',
                          isSelected: selectedOption == 'protection',
                          borderColor: Colors.green, // Bordure verte
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Option 3: Rémission (cliquable)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedOption = 'remission';
                          });
                        },
                        child: _buildOptionCard(
                          icon: Icons.favorite_border,
                          iconColor: Colors.blue,
                          iconBgColor: Colors.blue.shade50,
                          title: 'EN RÉMISSION',
                          subtitle: 'Ancien asthmatique stabilisé',
                          badge: 'Suivi de rechute',
                          badgeColor: Colors.blue.shade50,
                          badgeTextColor: Colors.blue,
                          footer: 'Monitoring adaptatif',
                          isSelected: selectedOption == 'remission',
                          borderColor: Colors.blue, // Bordure bleue
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      TextButton.icon(
                        onPressed: () => debugPrint('Aide demandée'),
                        icon: const Icon(Icons.help_outline, size: 18),
                        label: const Text('Besoin d\'aide pour choisir ?'),
                        style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // BOUTON CONTINUER (activé seulement si une option est sélectionnée)
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: selectedOption == null ? null : () {
                            // Navigation selon l'option sélectionnée
                            if (selectedOption == 'asthmatique') {
                              Navigator.push(
                                context, 
                                MaterialPageRoute(builder: (c) => const AsthmatiquePage())
                              );
                            } else if (selectedOption == 'protection') {
                              Navigator.push(
                                context, 
                                MaterialPageRoute(builder: (c) => const ProtectionPage())
                              );
                            }
                            else if (selectedOption == 'remission') {
                              Navigator.push(
                                context, 
                                MaterialPageRoute(builder: (c) => const RemissionPage())
                              );
                            }

                            // Pour la rémission, créer une autre page plus tard
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedOption == null 
                              ? Colors.grey[400] // Grisé si aucune sélection
                              : Colors.grey[600], // Actif si sélection
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)
                            ),
                            elevation: 0,
                            disabledBackgroundColor: Colors.grey[400], // Couleur quand désactivé
                          ),
                          child: Text(
                            'Continuer', 
                            style: TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.w600, 
                              color: selectedOption == null 
                                ? Colors.grey[300] // Texte gris clair si désactivé
                                : Colors.white, // Texte blanc si actif
                            )
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === FONCTION POUR CRÉER UNE CARTE D'OPTION ===
  Widget _buildOptionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required Color badgeTextColor,
    required String footer,
    required bool isSelected, // Nouveau paramètre pour savoir si c'est sélectionné
    required Color borderColor, // Couleur de la bordure
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // Bordure de la couleur spécifique si sélectionné
        border: Border.all(
          color: isSelected ? borderColor : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icône à gauche
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          
          const SizedBox(width: 16),
          
          // Contenu texte
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                // Badge coloré
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: badgeTextColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  footer,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          
          // Icône de check de la même couleur que la bordure si sélectionné
          if (isSelected)
            Icon(
              Icons.check_circle,
              color: borderColor,
              size: 24,
            ),
        ],
      ),
    );
  }
}