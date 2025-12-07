import 'package:flutter/material.dart';

// Page d'aide pour choisir sa catégorie
// Fichier : /lib/pages/aide_choix.dart
class AideChoixPage extends StatelessWidget {
  const AideChoixPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      
      // === BARRE DU HAUT ===
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.pop(context); // Retour à la page précédente
          },
        ),
        title: const Text(
          'Besoin d\'aide pour choisir ?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      
      // === CONTENU ===
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Texte d'introduction
            Text(
              'Choisis la catégorie qui te correspond le mieux pour profiter d\'un suivi personnalisé.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // === OPTION 1 : ASTHMATIQUE ===
            _buildOptionCard(
              context,
              number: '1',
              title: 'Je suis asthmatique',
              color: Colors.red,
              selectionCriteria: [
                'Tu as déjà reçu un diagnostic d\'asthme par un professionnel de santé.',
                'Tu fais parfois des crises ou difficultés respiratoires.',
                'Tu utilises un traitement comme un inhalateur (bleu, orange, etc.).',
                'Tu veux surveiller ton environnement pour éviter les déclencheurs (pollution, poussière, pollen…).',
              ],
              benefits: [
                'Des alertes plus strictes',
                'Des recommandations rapides',
                'Des informations sur les risques selon l\'air',
                'Des actions immédiates en cas de gêne respiratoire',
              ],
            ),
            
            const SizedBox(height: 24),
            
            // === OPTION 2 : PROTECTION ===
            _buildOptionCard(
              context,
              number: '2',
              title: 'Je veux me protéger',
              color: Colors.green,
              selectionCriteria: [
                'Tu n\'es pas asthmatique.',
                'Mais tu veux surveiller ton environnement parce que tu veux rester en bonne santé.',
                'Tu es sensible à la qualité de l\'air (fatigue, irritation, pollution…).',
                'Tu veux adopter de bonnes habitudes (prévention, pollution, air intérieur…).',
              ],
              benefits: [
                'Conseils pour éviter l\'exposition',
                'Bons gestes du quotidien',
                'Alertes quand la qualité de l\'air change',
                'Informations simples et rapides',
              ],
            ),
            
            const SizedBox(height: 24),
            
            // === OPTION 3 : RÉMISSION ===
            _buildOptionCard(
              context,
              number: '3',
              title: 'Je suis en rémission',
              color: Colors.blue,
              selectionCriteria: [
                'Tu as déjà eu de l\'asthme, mais ta santé s\'est améliorée.',
                'Tu ne fais plus ou presque plus de crises.',
                'Tu veux rester vigilant(e) pour éviter une rechute.',
                'Tu suis encore parfois un contrôle médical ou un traitement léger.',
              ],
              benefits: [
                'Suivi plus léger',
                'Conseils pour maintenir une bonne respiration',
                'Alertes modérées sur les risques',
                'Rappels pour éviter les facteurs déclencheurs',
              ],
            ),
            
            const SizedBox(height: 32),
            
            // === BOUTON RETOUR ===
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Retour à la page d'accueil
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Retour à l\'accueil',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // === FONCTION POUR CRÉER UNE CARTE D'OPTION ===
  Widget _buildOptionCard(
    BuildContext context, {
    required String number,
    required String title,
    required Color color,
    required List<String> selectionCriteria,
    required List<String> benefits,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          // ignore: deprecated_member_use
          color: color.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec numéro et titre
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Critères de sélection
          Text(
            'Sélectionne cette option si :',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          
          const SizedBox(height: 12),
          
          ...selectionCriteria.map((criteria) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    criteria,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
          
          const SizedBox(height: 20),
          
          // Avantages
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cette catégorie donne :',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 12),
                ...benefits.map((benefit) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: color,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          benefit,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}