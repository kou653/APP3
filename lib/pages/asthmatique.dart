import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'env.dart'; // Import de la page environnement
import 'ecran_historique_crises.dart';
import 'ecran_alertes_predictions.dart';
import 'ecran_profil.dart';
import '../state/app_state.dart';
import 'chat_page.dart';

// Page du tableau de bord pour les asthmatiques
// Fichier : /lib/pages/asthmatique.dart
class AsthmatiquePage extends StatelessWidget {
  const AsthmatiquePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      
      // === BARRE DU HAUT ===
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.blue,
            child: const Text(
              'S',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bonjour Sophie',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Asthme contrôlé',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Badge LIVE
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Icône Bluetooth
          IconButton(
            icon: const Icon(Icons.bluetooth, color: Colors.blue),
            onPressed: () {},
          ),
          // Icône Notifications
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.black54),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      
      // === CONTENU ===
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === CARTE RISQUE FAIBLE ===
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Cercle avec score
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          value: 0.18,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey[200],
                          color: Colors.green,
                        ),
                      ),
                      Column(
                        children: [
                          const Text(
                            '18',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '/100',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'RISQUE FAIBLE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Votre asthme est bien contrôlé',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // === TITRE : Données vitales ===
            const Text(
              'Données vitales en temps réel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // === GRILLE 2x2 ===
            Row(
              children: [
                Expanded(
                  child: _buildVitalCard(
                    'SpO2',
                    '98%',
                    'Mesuré il y a 3min',
                    Icons.favorite_border,
                    Colors.blue,
                    [0.3, 0.5, 0.7, 0.6, 0.8, 0.75, 0.85],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildVitalCard(
                    'Respiration',
                    '14/min',
                    'Normal (12-20)',
                    Icons.air,
                    Colors.blue,
                    null,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildVitalCard(
                    'Cœur',
                    '68 bpm',
                    'Repos normal',
                    Icons.favorite,
                    Colors.blue,
                    [0.5, 0.6, 0.55, 0.7, 0.65, 0.6, 0.7],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildVitalCard(
                    'Température',
                    '36.7°C',
                    'Normale',
                    Icons.thermostat,
                    Colors.blue,
                    null,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // === CARTES AIR ET ACTIVITÉ ===
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Air (AQI 32)',
                    'Bon',
                    'Abidjan Centre',
                    Icons.cloud_outlined,
                    Colors.blue,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    'Activité',
                    'Repos',
                    '2,340 pas aujourd\'hui',
                    Icons.directions_walk,
                    Colors.blue,
                    Colors.grey,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // === GRAPHIQUE ÉVOLUTION 24H ===
            const Text(
              'Évolution 24 heures',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 12),
            
            _buildEvolutionChart(),
            
            const SizedBox(height: 24),
            
            // === HISTORIQUE TRAITEMENTS ===
            const Text(
              'Historique traitements',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 12),
            
            _buildTreatmentItem(
              'Inhalateur préventif',
              '08h00',
              Colors.green,
              true,
            ),
            const SizedBox(height: 8),
            _buildTreatmentItem(
              'Corticoïde inhalé',
              '08h05',
              Colors.green,
              true,
            ),
            const SizedBox(height: 8),
            _buildTreatmentItem(
              'Prochain : Inhalateur',
              '20h00 - Dans 4h',
              Colors.purple,
              false,
            ),
            
            const SizedBox(height: 24),
            
            // === ACTIONS RAPIDES ===
            const Text(
              'Actions rapides',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 12),
            
            _buildActionButton(
              'DÉCLARER UNE CRISE',
              Colors.red,
              Icons.warning_amber,
            ),
            
            const SizedBox(height: 12),
            
            _buildActionOutlineButton(
              'J\'ai pris mon traitement',
              Icons.medication,
            ),
            
            const SizedBox(height: 12),
            
            _buildActionOutlineButton(
              'Parler à l\'assistant IA',
              Icons.chat_bubble_outline,
            ),
            
            const SizedBox(height: 12),
            
            _buildActionOutlineButton(
              'Voir analyse complète',
              Icons.bar_chart,
            ),
            
            const SizedBox(height: 20),
            
            // === CARTE VIGILANCE ===
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VIGILANCE',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pic de pollution prévu à 15h',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Voir recommandations',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 80), // Espace pour la barre de navigation
          ],
        ),
      ),
      
      // === BARRE DE NAVIGATION DU BAS ===
      bottomNavigationBar: Builder(builder: (context) {
        final hide = AppState.hideCrises;
        final labels = hide
            ? ['Accueil', 'Environnement', 'Alertes', 'Profil']
            : ['Accueil', 'Environnement', 'Crises', 'Alertes', 'Profil'];
        final currentIndex = labels.indexOf('Accueil');
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatPage()),
          );
        },
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // ↑ augmente cette valeur
        ),
        child: const Icon(Icons.chat_bubble_outline),
      ),
    );
  }

  // === CARTE DE DONNÉES VITALES ===
  Widget _buildVitalCard(
    String label,
    String value,
    String subtitle,
    IconData icon,
    Color iconColor,
    List<double>? chartData,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor, size: 20),
              Icon(Icons.remove, color: Colors.grey[400], size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.green[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (chartData != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: chartData.map((value) {
                  return Container(
                    width: 8,
                    height: value * 30,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade200,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // === CARTE INFO (Air, Activité) ===
  Widget _buildInfoCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color iconColor,
    Color valueColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor, size: 20),
              Icon(Icons.remove, color: Colors.grey[400], size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // === GRAPHIQUE ÉVOLUTION ===
  Widget _buildEvolutionChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 25,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
                  if (value.toInt() >= 0 && value.toInt() < days.length) {
                    return Text(
                      days[value.toInt()],
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            // Ligne bleue (Respiration)
            LineChartBarData(
              spots: [
                FlSpot(0, 98),
                FlSpot(1, 97),
                FlSpot(2, 98),
                FlSpot(3, 97),
                FlSpot(4, 98),
                FlSpot(5, 98),
                FlSpot(6, 98),
              ],
              color: Colors.blue,
              barWidth: 2,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            ),
            // Ligne orange (Score risque)
            LineChartBarData(
              spots: [
                FlSpot(0, 18),
                FlSpot(1, 20),
                FlSpot(2, 19),
                FlSpot(3, 21),
                FlSpot(4, 20),
                FlSpot(5, 19),
                FlSpot(6, 18),
              ],
              color: Colors.orange,
              barWidth: 2,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            ),
            // Ligne verte (SpO2)
            LineChartBarData(
              spots: [
                FlSpot(0, 12),
                FlSpot(1, 13),
                FlSpot(2, 14),
                FlSpot(3, 13),
                FlSpot(4, 14),
                FlSpot(5, 14),
                FlSpot(6, 15),
              ],
              color: Colors.green,
              barWidth: 2,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  // === ITEM TRAITEMENT ===
  Widget _buildTreatmentItem(String title, String time, Color color, bool isDone) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDone ? color.withValues(alpha: 0.1) : Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDone ? color.withValues(alpha: 0.3) : Colors.purple.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.medication : Icons.schedule,
            color: isDone ? color : Colors.purple,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (isDone)
            Icon(Icons.check_circle, color: color, size: 24),
        ],
      ),
    );
  }

  // === BOUTON ACTION PLEIN ===
  Widget _buildActionButton(String text, Color color, IconData icon) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === BOUTON ACTION OUTLINE ===
  Widget _buildActionOutlineButton(String text, IconData icon) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.grey[700], size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}