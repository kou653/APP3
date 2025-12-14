// Importe le package de base de Flutter et le widget de la barre de navigation.
import 'package:flutter/material.dart';
import 'env.dart';
import 'ecran_historique_crises.dart';
import 'ecran_alertes_predictions.dart';
import '../state/app_state.dart';

// Définit le widget pour l'écran de profil.
class EcranProfil extends StatelessWidget {
  const EcranProfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(context),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: _buildAsthmaDetails(context),
                ),
                const SizedBox(height: 16),
                _buildContactsSection(context),
                const SizedBox(height: 16),
                _buildObjectivesSection(context),
                const SizedBox(height: 16),
                _buildSettingsSection(context),
                const SizedBox(height: 16),
                _buildDataSection(context),
                const SizedBox(height: 80), // Espace pour la barre de navigation
              ],
            ),
          ),
        ],
      ),
      ),
      
      // === BARRE DE NAVIGATION ===
      bottomNavigationBar: Builder(builder: (context) {
        final hide = AppState.hideCrises;
        final labels = hide
            ? ['Accueil', 'Environnement', 'Alertes', 'Profil']
            : ['Accueil', 'Environnement', 'Crises', 'Alertes', 'Profil'];
        final currentIndex = labels.indexOf('Profil');
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

  // Widget pour la section supérieure (header).
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Text('S', style: TextStyle(fontSize: 32, color: Color(0xFF6A11CB))),
            ),
            const SizedBox(height: 12),
            const Text('Sophie', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('32 ans', style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 12),
            Chip(
              label: const Text('Asthme allergique'),
              backgroundColor: Colors.white.withValues(alpha: 0.9),
              labelStyle: const TextStyle(color: Color(0xFF6A11CB), fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Avec RespirIA depuis 145 jours', style: TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // Widget pour la carte "Mon asthme".
  Widget _buildAsthmaDetails(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite_border, color: Colors.red.shade300),
                const SizedBox(width: 8),
                Text('Mon asthme', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoRow('Type d\'asthme', 'Asthme allergique'),
            _buildInfoRow('Sévérité', 'Modéré', isChip: true),
            _buildInfoRow('Date diagnostic', '15/03/2015'),
            const Divider(height: 30, thickness: 1, color: Color(0xFFF0F0F0)),
            const Text('Allergènes connus', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              children: const [Chip(label: Text('Pollen')), Chip(label: Text('Acariens')), Chip(label: Text('Chat'))],
            ),
            const Divider(height: 30, thickness: 1, color: Color(0xFFF0F0F0)),
            const Text('Traitements actuels', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildTreatmentItem('Ventoline'),
            _buildTreatmentItem('Corticoïde inhalé'),
            _buildTreatmentItem('Antihistaminique'),
          ],
        ),
      ),
    );
  }

  // Widget pour la section "Contacts d'urgence".
  Widget _buildContactsSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Contacts d\'urgence', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: const Text('Modifier')),
              ],
            ),
            const SizedBox(height: 10),
            _buildContactItem('M', 'Marc (conjoint)', '+33 6 12 34 56 78', Colors.blue.shade100, Colors.blue.shade800),
            const Divider(),
            _buildContactItem('D', 'Dr. Dubois', '+33 1 23 45 67 89', Colors.indigo.shade50, Colors.indigo.shade800),
          ],
        ),
      ),
    );
  }

  // Widget pour la section "Mes objectifs".
  Widget _buildObjectivesSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
       color: const Color(0xFFF0FFF8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mes objectifs', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Réduire les crises de 50%', style: TextStyle(fontSize: 16, color: Colors.black87)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(
                  child: LinearProgressIndicator(
                    value: 0.6,
                    backgroundColor: Colors.black12,
                    color: Colors.green,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('60%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black54)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour la section "Paramètres".
  Widget _buildSettingsSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
              children: [
                Icon(Icons.settings_outlined, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text('Paramètres', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            _buildSettingItem('Notifications', 'Alertes et rappels', Switch(value: true, onChanged: (val) {})),
            _buildSettingItem('Gestion des données', 'Collecte maximale', const Text('Voir', style: TextStyle(color: Colors.blue))),
            _buildSettingItem('Bracelet connecté', 'Déconnecté', const Text('Voir', style: TextStyle(color: Colors.blue))),
            _buildSettingItem('Langue', 'Français', const Text('Changer', style: TextStyle(color: Colors.blue))),
          ],
        ),
      ),
    );
  }

  // Widget pour la section "Mes données".
  Widget _buildDataSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.download_outlined, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text('Mes données', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            _buildDataItem(Icons.download_outlined, 'Export historique (CSV)'),
            const SizedBox(height: 8),
            _buildDataItem(Icons.person_outline, 'Rapport pour médecin'),
            const SizedBox(height: 8),
            _buildDataItem(Icons.logout, 'Supprimer mes données', color: Colors.red),
          ],
        ),
      ),
    );
  }

  // --- FONCTIONS D'AIDE ---

  Widget _buildInfoRow(String label, String value, {bool isChip = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 15)),
          if (isChip)
            Chip(
              label: Text(value),
              backgroundColor: Colors.yellow.shade100,
              labelStyle: TextStyle(color: Colors.yellow.shade800, fontWeight: FontWeight.bold),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              visualDensity: VisualDensity.compact,
            )
          else
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildTreatmentItem(String traitement) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(Icons.circle, color: Colors.blue.shade600, size: 8),
          const SizedBox(width: 10),
          Text(traitement, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildContactItem(String initial, String name, String phone, Color bgColor, Color fgColor) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: bgColor,
        child: Text(initial, style: TextStyle(color: fgColor, fontWeight: FontWeight.bold)),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(phone, style: const TextStyle(color: Colors.grey)),
      trailing: IconButton(icon: const Icon(Icons.phone_outlined), onPressed: () {}),
    );
  }

  Widget _buildSettingItem(String title, String subtitle, Widget trailingWidget) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
      trailing: trailingWidget,
    );
  }

  Widget _buildDataItem(IconData icon, String text, {Color? color}) {
    final itemColor = color ?? Colors.black87;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, color: itemColor, size: 20),
        label: Text(text, style: TextStyle(color: itemColor, fontWeight: FontWeight.w500)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color?.withValues(alpha: 0.5) ?? Colors.grey.shade300),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}