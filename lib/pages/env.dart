// Fichier : /lib/pages/env.dart - VERSION DYNAMIQUE
import 'package:flutter/material.dart';
import 'ecran_historique_crises.dart';
import 'ecran_alertes_predictions.dart';
import 'ecran_profil.dart';
import '../state/app_state.dart';
import '../services/api_service.dart';
import '../services/auth_storage.dart';
import '../models/environment.dart';

class EnvironnementPage extends StatefulWidget {
  const EnvironnementPage({super.key});

  @override
  State<EnvironnementPage> createState() => _EnvironnementPageState();
}

class _EnvironnementPageState extends State<EnvironnementPage> {
  AirQuality? _airQuality;
  Weather? _weather;
  bool _isLoading = true;
  String? _error;
  String _city = 'Abidjan';

  @override
  void initState() {
    super.initState();
    _loadEnvironmentData();
  }

  Future<void> _loadEnvironmentData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final token = AuthStorage.accessToken;
    if (token == null) {
      setState(() {
        _error = 'Non authentifié';
        _isLoading = false;
      });
      return;
    }

    try {
      // Récupérer la ville de l'utilisateur
      final savedCity = AuthStorage.city;
      if (savedCity != null) {
        _city = savedCity;
      }

      // Charger la qualité de l'air
      final airResult = await ApiService.getAirQuality(token: token);
      
      // Charger la météo
      final weatherResult = await ApiService.getWeather(token: token);

      if (mounted) {
        setState(() {
          if (airResult['success'] == true) {
            final airData = airResult['data'];
            if (airData is List && airData.isNotEmpty) {
              _airQuality = AirQuality.fromJson(
                Map<String, dynamic>.from(airData[0])
              );
            } else if (airData is Map) {
              _airQuality = AirQuality.fromJson(
                Map<String, dynamic>.from(airData)
              );
            }
          }

          if (weatherResult['success'] == true) {
            final weatherData = weatherResult['data'];
            if (weatherData is List && weatherData.isNotEmpty) {
              _weather = Weather.fromJson(
                Map<String, dynamic>.from(weatherData[0])
              );
            } else if (weatherData is Map) {
              _weather = Weather.fromJson(
                Map<String, dynamic>.from(weatherData)
              );
            }
          }


          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erreur de chargement: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Environnement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _city,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadEnvironmentData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadEnvironmentData,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadEnvironmentData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Carte interactive
                        Container(
                          height: 140,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade100,
                                Colors.yellow.shade100,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Carte interactive',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Zones colorées selon qualité air',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Mon environnement actuel
                        _buildCurrentEnvironment(),
                        const SizedBox(height: 20),

                        // Météo actuelle
                        if (_weather != null) _buildWeatherCard(),
                        const SizedBox(height: 20),

                        // Recommandations
                        _buildRecommendations(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildCurrentEnvironment() {
    if (_airQuality == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('Données de qualité d\'air non disponibles'),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mon environnement actuel',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),

          // Cercle qualité de l'air
          Center(
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: _airQuality!.color,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${_airQuality!.aqi}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Qualité de l\'air',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _airQuality!.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _airQuality!.aqiLevelFr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _airQuality!.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Polluants
          _buildPollutantBar('PM2.5', _airQuality!.pm25Display, (_airQuality!.pollutants['pm25'] ?? 0) / 100),
          const SizedBox(height: 12),
          _buildPollutantBar('PM10', _airQuality!.pm10Display, (_airQuality!.pollutants['pm10'] ?? 0) / 100),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Météo actuelle',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_weather!.weatherIcon, size: 48, color: Colors.orange),
                      const SizedBox(width: 12),
                      Text(
                        _weather!.temperatureDisplay,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _weather!.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Ressenti: ${_weather!.feelsLikeDisplay}'),
                  const SizedBox(height: 4),
                  Text('Humidité: ${_weather!.humidityDisplay}'),
                  const SizedBox(height: 4),
                  Text('Vent: ${_weather!.windSpeedDisplay}'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    if (_airQuality == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommandations intelligentes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ..._airQuality!.healthRecommendations.map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildRecommendation(
                  Icons.info,
                  rec,
                  Colors.blue,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPollutantBar(String label, String value, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.grey[200],
            color: progress < 0.4 ? Colors.green : (progress < 0.6 ? Colors.yellow : Colors.orange),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendation(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey[600],
      currentIndex: 1,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      backgroundColor: Colors.white,
      elevation: 8,
      onTap: (index) {
        final hide = AppState.hideCrises;
        final labels = hide
            ? ['Accueil', 'Environnement', 'Alertes', 'Profil']
            : ['Accueil', 'Environnement', 'Crises', 'Alertes', 'Profil'];
        final label = labels[index];
        if (label == 'Accueil') {
          Navigator.popUntil(context, (route) => route.isFirst);
        } else if (label == 'Environnement') {
          // Déjà sur cette page
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
  }
}