// Fichier : /lib/pages/ecran_profil.dart - VERSION DYNAMIQUE
import 'package:flutter/material.dart';
import 'env.dart';
import 'ecran_historique_crises.dart';
import 'ecran_alertes_predictions.dart';
import '../state/app_state.dart';
import '../services/api_service.dart';
import '../services/auth_storage.dart';
import '../models/user_profile.dart';
import 'login_page.dart';

class EcranProfil extends StatefulWidget {
  const EcranProfil({super.key});

  @override
  State<EcranProfil> createState() => _EcranProfilState();
}

class _EcranProfilState extends State<EcranProfil> {
  User? _user;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
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
      final result = await ApiService.getUserProfile(token: token);

      if (result['success'] == true) {
        final userData = result['data'];
        
        if (mounted) {
          setState(() {
            _user = User.fromJson(userData);
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

  Future<void> _logout() async {
    await AuthStorage.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
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
                        onPressed: _loadUserProfile,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUserProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _buildHeader(context),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Transform.translate(
                                offset: const Offset(0, -40),
                                child: _buildProfileDetails(context),
                              ),
                              const SizedBox(height: 16),
                              _buildSettingsSection(context),
                              const SizedBox(height: 16),
                              _buildDataSection(context),
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    if (_user == null) return const SizedBox.shrink();

    final initial = _user!.displayName.isNotEmpty ? _user!.displayName[0].toUpperCase() : '?';

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
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Text(
                initial,
                style: const TextStyle(fontSize: 32, color: Color(0xFF6A11CB)),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _user!.displayName,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _user!.email,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Chip(
              label: Text(_user!.profile.profileTypeFr),
              backgroundColor: Colors.white.withValues(alpha: 0.9),
              labelStyle: const TextStyle(color: Color(0xFF6A11CB), fontWeight: FontWeight.bold),
            ),
            if (_user!.profile.daysWithoutSymptoms > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Sans symptômes depuis ${_user!.profile.daysWithoutSymptoms} jours',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetails(BuildContext context) {
    if (_user == null) return const SizedBox.shrink();

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
                Icon(Icons.person, color: Colors.blue.shade300),
                const SizedBox(width: 8),
                Text(
                  'Informations personnelles',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoRow('Nom complet', _user!.fullName),
            _buildInfoRow('Email', _user!.email),
            if (_user!.phone != null) _buildInfoRow('Téléphone', _user!.phone!),
            _buildInfoRow('Type de profil', _user!.profile.profileTypeFr, isChip: true),
            _buildInfoRow('Ville', _user!.profile.city),
            _buildInfoRow('Alertes', _user!.profile.alertsEnabled ? 'Activées' : 'Désactivées', isChip: true),
          ],
        ),
      ),
    );
  }

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
                Text(
                  'Paramètres',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildSettingItem(
              'Notifications',
              'Alertes et rappels',
              Switch(
                value: _user?.profile.alertsEnabled ?? true,
                onChanged: (val) {
                  // TODO: Implémenter la mise à jour
                },
              ),
            ),
            _buildSettingItem(
              'Langue',
              'Français',
              const Text('Changer', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }

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
                Icon(Icons.data_usage, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'Données & Compte',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDataItem(Icons.download_outlined, 'Export historique (CSV)'),
            const SizedBox(height: 8),
            _buildDataItem(Icons.person_outline, 'Rapport pour médecin'),
            const SizedBox(height: 8),
            _buildDataItem(Icons.logout, 'Se déconnecter', color: Colors.orange, onTap: _logout),
            const SizedBox(height: 8),
            _buildDataItem(Icons.delete_outline, 'Supprimer mes données', color: Colors.red),
          ],
        ),
      ),
    );
  }

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
              backgroundColor: Colors.blue.shade50,
              labelStyle: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              visualDensity: VisualDensity.compact,
            )
          else
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
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

  Widget _buildDataItem(IconData icon, String text, {Color? color, VoidCallback? onTap}) {
    final itemColor = color ?? Colors.black87;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
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

  Widget _buildBottomNav() {
    return Builder(builder: (context) {
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
          }
        },
        items: AppState.hideCrises
            ? const [
                BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Accueil'),
                BottomNavigationBarItem(icon: Icon(Icons.insert_drive_file), label: 'Environnement'),
                BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: 'Alertes'),
                BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
              ]
            : const [
                BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Accueil'),
                BottomNavigationBarItem(icon: Icon(Icons.insert_drive_file), label: 'Environnement'),
                BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Crises'),
                BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: 'Alertes'),
                BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
              ],
      );
    });
  }
}