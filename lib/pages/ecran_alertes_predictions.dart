// Fichier : /lib/pages/ecran_alertes_predictions.dart - VERSION DYNAMIQUE
import 'package:flutter/material.dart';
import 'env.dart';
import 'ecran_historique_crises.dart';
import 'ecran_profil.dart';
import '../services/api_service.dart';
import '../services/auth_storage.dart';
import '../models/alert.dart';

class EcranAlertesPredictions extends StatefulWidget {
  const EcranAlertesPredictions({super.key});

  @override
  State<EcranAlertesPredictions> createState() => _EcranAlertesPredictionsState();
}

class _EcranAlertesPredictionsState extends State<EcranAlertesPredictions> {
  List<Alert> _alerts = [];
  bool _isLoading = true;
  String? _error;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
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
      // Charger toutes les alertes
      final result = await ApiService.getAlerts(token: token);

      if (result['success'] == true) {
        final data = result['data'];
        final results = data['results'] as List;
        
        if (mounted) {
          setState(() {
            _alerts = results.map((json) => Alert.fromJson(json)).toList();
            _unreadCount = _alerts.where((a) => !a.isRead).length;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = result['error'] ?? 'Erreur de chargement';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erreur: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAsRead(Alert alert) async {
    if (alert.isRead) return;

    final token = AuthStorage.accessToken;
    if (token == null) return;

    try {
      final result = await ApiService.markAlertAsRead(
        token: token,
        alertId: alert.id,
      );

      if (result['success'] == true && mounted) {
        setState(() {
          final index = _alerts.indexWhere((a) => a.id == alert.id);
          if (index != -1) {
            _alerts[index] = alert.copyWith(isRead: true);
            _unreadCount = _alerts.where((a) => !a.isRead).length;
          }
        });
      }
    } catch (e) {
      print('Erreur lors du marquage comme lu: $e');
    }
  }

  Color _getSeverityColor(String severity) {
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

  IconData _getSeverityIcon(String severity) {
    switch (severity) {
      case 'INFO':
        return Icons.info_outline;
      case 'WARNING':
        return Icons.warning_amber_rounded;
      case 'CRITICAL':
        return Icons.error_outline;
      default:
        return Icons.notifications;
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
              'Alertes & Prédictions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              '$_unreadCount non lue(s)',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadAlerts,
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
                        onPressed: _loadAlerts,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadAlerts,
                  child: _alerts.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Aucune alerte',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Notifications intelligentes basées sur l\'IA',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 24),

                              // Liste des alertes
                              ..._alerts.map((alert) => Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _buildCarteAlerte(
                                      context,
                                      alert: alert,
                                      niveauRisque: alert.alertTypeDescription,
                                      details: [alert.message],
                                      timestamp: alert.timeAgo,
                                      couleur: _getSeverityColor(alert.severity),
                                      icone: _getSeverityIcon(alert.severity),
                                      onTap: () => _markAsRead(alert),
                                    ),
                                  )),

                              const SizedBox(height: 24),
                              _buildCarteIA(context),
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildCarteAlerte(
    BuildContext context, {
    required Alert alert,
    required String niveauRisque,
    required List<String> details,
    required String timestamp,
    required Color couleur,
    required IconData icone,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: couleur.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: alert.isRead ? couleur.withValues(alpha: 0.3) : couleur,
            width: alert.isRead ? 1.0 : 1.5,
          ),
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: couleur,
                        ),
                  ),
                ),
                if (!alert.isRead)
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: couleur,
                      shape: BoxShape.circle,
                    ),
                  ),
                const SizedBox(width: 8),
                Text(timestamp, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            ...details.map((detail) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    detail,
                    style: TextStyle(
                      color: getCouleurFoncee(couleur),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: couleur.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                alert.severityFr,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: couleur,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color getCouleurFoncee(Color couleur) {
    final hsl = HSLColor.fromColor(couleur);
    final hslFonce = hsl.withLightness((hsl.lightness - 0.2).clamp(0.1, 1.0));
    return hslFonce.toColor();
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
                Expanded(child: _buildStatBox('96%', 'Précision\nmodèle')),
                const SizedBox(width: 12),
                Expanded(child: _buildStatBox('${_alerts.length}', 'Alertes\nenvoyées')),
                const SizedBox(width: 12),
                Expanded(child: _buildStatBox('24/7', 'Surveillance\nactive')),
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

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey[600],
      currentIndex: 3,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      backgroundColor: Colors.white,
      elevation: 8,
      onTap: (index) {
        if (index == 0) {
          Navigator.popUntil(context, (route) => route.isFirst);
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EnvironnementPage()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EcranHistoriqueCrises()),
          );
        } else if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EcranProfil()),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Accueil'),
        BottomNavigationBarItem(icon: Icon(Icons.insert_drive_file_outlined), activeIcon: Icon(Icons.insert_drive_file), label: 'Environnement'),
        BottomNavigationBarItem(icon: Icon(Icons.show_chart), activeIcon: Icon(Icons.show_chart), label: 'Crises'),
        BottomNavigationBarItem(icon: Icon(Icons.info_outline), activeIcon: Icon(Icons.info), label: 'Alertes'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
      ],
    );
  }
}