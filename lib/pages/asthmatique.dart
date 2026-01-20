import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'env.dart';
import 'ecran_historique_crises.dart';
import 'ecran_alertes_predictions.dart';
import 'ecran_profil.dart';
import '../state/app_state.dart';
import 'chat_page.dart';
import '../models/sensor_data.dart';
import '../models/environment.dart';
import '../models/alert.dart';
import '../services/api_service.dart';
import '../services/auth_storage.dart';
import '../services/crisis_service.dart';

class AsthmatiquePage extends StatefulWidget {
  const AsthmatiquePage({super.key});

  @override
  State<AsthmatiquePage> createState() => _AsthmatiquePageState();
}

class _AsthmatiquePageState extends State<AsthmatiquePage> {
  // Données capteurs
  SensorData? latestSensor;
  RiskScore? riskScore;
  AirQuality? airQuality;
  Weather? weather;
  
  // Statistiques
  Map<String, dynamic>? stats;
  List<Alert> alerts = [];
  
  // État
  bool isLoading = true;
  String? error;
  String? userName;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  /// Charge toutes les données du tableau de bord
  Future<void> _loadDashboardData() async {
    try {
      final token = AuthStorage.getAccessToken();
      if (token == null) {
        setState(() {
          error = "Utilisateur non connecté.";
          isLoading = false;
        });
        return;
      }

      // Récupérer le nom de l'utilisateur
      final userNameStored = AuthStorage.getUserName();
      
      // Appels parallèles pour charger les données
      final results = await Future.wait([
        ApiService.getLatestSensorData(token: token),
        ApiService.getRiskScore(token: token),
        ApiService.getAirQuality(token: token),
        ApiService.getWeather(token: token),
        ApiService.getSensorStats(token: token, period: '24h'),
      ]);

      if (!mounted) return;

      // Vérifier les résultats
      final sensorRes = results[0];
      final riskRes = results[1];
      final airRes = results[2];
      final weatherRes = results[3];
      final statsRes = results[4];

      if (sensorRes['success'] &&
          riskRes['success'] &&
          airRes['success'] &&
          weatherRes['success']) {
        setState(() {
          latestSensor = SensorData.fromJson(sensorRes['data']);
          riskScore = RiskScore.fromJson(riskRes['data']);
          airQuality = AirQuality.fromJson(airRes['data']);
          weather = Weather.fromJson(weatherRes['data']);
          if (statsRes['success']) {
            stats = statsRes['data'];
          }
          userName = userNameStored ?? 'Sophie';
          isLoading = false;
        });

        // Charger les alertes en arrière-plan
        _loadAlerts(token);
      } else {
        setState(() {
          error =
              "Erreur lors du chargement des données. Veuillez réessayer.";
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = "Erreur: ${e.toString()}";
          isLoading = false;
        });
      }
    }
  }

  /// Charge les alertes
  Future<void> _loadAlerts(String token) async {
    try {
      final result = await ApiService.getAlerts(token: token);
      if (!mounted) return;
      
      if (result['success']) {
        final List<dynamic> alertsData = result['data']['results'] ?? [];
        setState(() {
          alerts = alertsData
              .map((a) => Alert.fromJson(a))
              .toList()
              .take(3)
              .toList(); // Limite à 3 alertes
        });
      }
    } catch (e) {
      print('[AsthmatiquePage] Erreur lors du chargement des alertes: $e');
    }
  }

  /// Recharge les données
  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    await _loadDashboardData();
  }

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
            child: Text(
              (userName ?? 'S')[0].toUpperCase(),
              style: const TextStyle(
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
            Text(
              'Bonjour ${userName ?? "Sophie"}',
              style: const TextStyle(
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
              child: Text(
                riskScore?.riskLevel == 'LOW' 
                    ? 'Asthme contrôlé' 
                    : 'Surveillance',
                style: TextStyle(
                  fontSize: 11,
                  color: riskScore?.riskLevel == 'LOW' 
                      ? Colors.green 
                      : Colors.orange,
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
                icon:
                    const Icon(Icons.notifications_outlined, color: Colors.black54),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EcranAlertesPredictions()),
                  );
                },
              ),
              if (alerts.isNotEmpty)
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text(
                        error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refreshData,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _buildContent(),

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
                MaterialPageRoute(
                    builder: (context) => const EcranHistoriqueCrises()),
              );
            } else if (label == 'Alertes') {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EcranAlertesPredictions()),
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
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Icon(Icons.chat_bubble_outline),
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === CARTE RISQUE ===
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
                          value: (riskScore?.riskScore ?? 0) / 100,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey[200],
                          color: _getRiskColor(riskScore?.riskLevel),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '${riskScore?.riskScore ?? 0}',
                            style: const TextStyle(
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
                  Text(
                    riskScore?.riskLevelFr ?? 'RISQUE INCONNU',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    riskScore?.riskLevel == 'LOW'
                        ? 'Votre asthme est bien contrôlé'
                        : 'Surveillance recommandée',
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
                    latestSensor?.spo2Display ?? 'N/A',
                    latestSensor?.timeAgo ?? 'N/A',
                    Icons.favorite_border,
                    Colors.blue,
                    _generateChartData(latestSensor?.spo2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildVitalCard(
                    'Respiration',
                    latestSensor?.respiratoryRateDisplay ?? 'N/A',
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
                    latestSensor?.heartRateDisplay ?? 'N/A',
                    'Repos normal',
                    Icons.favorite,
                    Colors.blue,
                    _generateChartData(latestSensor?.heartRate),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildVitalCard(
                    'Température',
                    latestSensor?.temperatureDisplay ?? 'N/A',
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
                    'Air (AQI ${airQuality?.aqi ?? "?"})',
                    airQuality?.aqiLevelFr ?? 'Inconnu',
                    airQuality?.city ?? 'Abidjan',
                    Icons.cloud_outlined,
                    Colors.blue,
                    _getAirQualityColor(airQuality?.aqi),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    'Activité',
                    latestSensor?.activityLevelFr ?? 'Repos',
                    '${latestSensor?.steps ?? 0} pas',
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
            
            // === ALERTES ACTIVES ===
            if (alerts.isNotEmpty) ...[
              const Text(
                'Alertes actives',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              ...alerts.map((alert) => _buildAlertCard(alert)),
              const SizedBox(height: 24),
            ],
            
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
            if (riskScore != null && riskScore!.riskLevel == 'HIGH')
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.orange.shade700, size: 28),
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
                            'Votre risque a augmenté, soyez vigilant',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const EcranAlertesPredictions(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Détails',
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
            
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // === HELPERS ===

  Color _getRiskColor(String? riskLevel) {
    switch (riskLevel) {
      case 'LOW':
        return Colors.green;
      case 'MODERATE':
        return Colors.orange;
      case 'HIGH':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getAirQualityColor(int? aqi) {
    if (aqi == null) return Colors.grey;
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow;
    if (aqi <= 150) return Colors.orange;
    return Colors.red;
  }

  List<double> _generateChartData(int? value) {
    if (value == null) return [];
    final base = (value / 100).clamp(0.0, 1.0);
    return [base * 0.9, base * 0.95, base, base * 0.92, base * 0.98, base * 0.94, base];
  }

  Widget _buildAlertCard(Alert alert) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _getAlertColor(alert.severity).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getAlertColor(alert.severity).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline,
              color: _getAlertColor(alert.severity), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.alertTypeDescription,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alert.message,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            alert.timeAgo,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Color _getAlertColor(String severity) {
    switch (severity) {
      case 'INFO':
        return Colors.blue;
      case 'WARNING':
        return Colors.orange;
      case 'CRITICAL':
        return Colors.red;
      default:
        return Colors.grey;
    }
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
          if (chartData != null && chartData.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: chartData.map((value) {
                  return Container(
                    width: 8,
                    height: (value * 30).clamp(2, 30).toDouble(),
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
            // Ligne bleue (SpO2)
            LineChartBarData(
              spots: [
                FlSpot(0, (latestSensor?.spo2?.toDouble() ?? 98) - 94),
                FlSpot(1, (latestSensor?.spo2?.toDouble() ?? 97) - 94),
                FlSpot(2, (latestSensor?.spo2?.toDouble() ?? 98) - 94),
                FlSpot(3, (latestSensor?.spo2?.toDouble() ?? 97) - 94),
                FlSpot(4, (latestSensor?.spo2?.toDouble() ?? 98) - 94),
                FlSpot(5, (latestSensor?.spo2?.toDouble() ?? 98) - 94),
                FlSpot(6, (latestSensor?.spo2?.toDouble() ?? 98) - 94),
              ],
              color: Colors.blue,
              barWidth: 2,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            ),
            // Ligne orange (Score risque)
            LineChartBarData(
              spots: [
                FlSpot(0, (riskScore?.riskScore ?? 18) * 0.25),
                FlSpot(1, (riskScore?.riskScore ?? 20) * 0.25),
                FlSpot(2, (riskScore?.riskScore ?? 19) * 0.25),
                FlSpot(3, (riskScore?.riskScore ?? 21) * 0.25),
                FlSpot(4, (riskScore?.riskScore ?? 20) * 0.25),
                FlSpot(5, (riskScore?.riskScore ?? 19) * 0.25),
                FlSpot(6, (riskScore?.riskScore ?? 18) * 0.25),
              ],
              color: Colors.orange,
              barWidth: 2,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            ),
            // Ligne verte (Fréquence respiratoire)
            LineChartBarData(
              spots: [
                FlSpot(0, (latestSensor?.respiratoryRate?.toDouble() ?? 16) - 12),
                FlSpot(1, (latestSensor?.respiratoryRate?.toDouble() ?? 16) - 11),
                FlSpot(2, (latestSensor?.respiratoryRate?.toDouble() ?? 16) - 10),
                FlSpot(3, (latestSensor?.respiratoryRate?.toDouble() ?? 16) - 11),
                FlSpot(4, (latestSensor?.respiratoryRate?.toDouble() ?? 16) - 10),
                FlSpot(5, (latestSensor?.respiratoryRate?.toDouble() ?? 16) - 10),
                FlSpot(6, (latestSensor?.respiratoryRate?.toDouble() ?? 16) - 9),
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