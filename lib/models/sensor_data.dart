// Fichier : /lib/models/sensor_data.dart

/// Modèle pour les données des capteurs (bracelet)
class SensorData {
  final int? id;
  final DateTime timestamp;
  final int? spo2;
  final int? heartRate;
  final int? respiratoryRate;
  final double? temperature;
  final String? activityLevel;
  final int? steps;
  final int? riskScore;
  final String? riskLevel;
  final DateTime? createdAt;

  SensorData({
    this.id,
    required this.timestamp,
    this.spo2,
    this.heartRate,
    this.respiratoryRate,
    this.temperature,
    this.activityLevel,
    this.steps,
    this.riskScore,
    this.riskLevel,
    this.createdAt,
  });

  /// Créer depuis JSON (réponse API)
  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      spo2: json['spo2'],
      heartRate: json['heart_rate'],
      respiratoryRate: json['respiratory_rate'],
      temperature: json['temperature']?.toDouble(),
      activityLevel: json['activity_level'],
      steps: json['steps'],
      riskScore: json['risk_score'],
      riskLevel: json['risk_level'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  /// Convertir en JSON (pour envoyer à l'API)
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      if (spo2 != null) 'spo2': spo2,
      if (heartRate != null) 'heart_rate': heartRate,
      if (respiratoryRate != null) 'respiratory_rate': respiratoryRate,
      if (temperature != null) 'temperature': temperature,
      if (activityLevel != null) 'activity_level': activityLevel,
      if (steps != null) 'steps': steps,
      if (riskScore != null) 'risk_score': riskScore,
    };
  }

  /// Formater le niveau de risque en français
  String get riskLevelFr {
    switch (riskLevel) {
      case 'LOW':
        return 'RISQUE FAIBLE';
      case 'MODERATE':
        return 'RISQUE MODÉRÉ';
      case 'HIGH':
        return 'RISQUE ÉLEVÉ';
      case 'CRITICAL':
        return 'RISQUE CRITIQUE';
      default:
        return 'INCONNU';
    }
  }

  /// Formater l'activité en français
  String get activityLevelFr {
    switch (activityLevel) {
      case 'REST':
        return 'Repos';
      case 'LIGHT':
        return 'Activité légère';
      case 'MODERATE':
        return 'Activité modérée';
      case 'INTENSE':
        return 'Activité intense';
      default:
        return 'Inconnu';
    }
  }

  /// SpO2 formaté pour l'affichage
  String get spo2Display => spo2 != null ? '$spo2%' : 'N/A';

  /// Fréquence cardiaque formatée
  String get heartRateDisplay => heartRate != null ? '$heartRate bpm' : 'N/A';

  /// Fréquence respiratoire formatée
  String get respiratoryRateDisplay => respiratoryRate != null ? '$respiratoryRate/min' : 'N/A';

  /// Température formatée
  String get temperatureDisplay => temperature != null ? '${temperature!.toStringAsFixed(1)}°C' : 'N/A';

  /// Temps écoulé depuis la mesure
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else {
      return 'Il y a ${difference.inDays}j';
    }
  }
}

/// Modèle pour le score de risque
class RiskScore {
  final int riskScore;
  final String riskLevel;
  final DateTime timestamp;

  RiskScore({
    required this.riskScore,
    required this.riskLevel,
    required this.timestamp,
  });

  factory RiskScore.fromJson(Map<String, dynamic> json) {
    return RiskScore(
      riskScore: json['risk_score'] ?? 0,
      riskLevel: json['risk_level'] ?? 'LOW',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
    );
  }

  String get riskLevelFr {
    switch (riskLevel) {
      case 'LOW':
        return 'RISQUE FAIBLE';
      case 'MODERATE':
        return 'RISQUE MODÉRÉ';
      case 'HIGH':
        return 'RISQUE ÉLEVÉ';
      case 'CRITICAL':
        return 'RISQUE CRITIQUE';
      default:
        return 'INCONNU';
    }
  }
}

/// Modèle pour les statistiques
class SensorStats {
  final String period;
  final double? avgSpo2;
  final int? minSpo2;
  final double? avgHeartRate;
  final int? maxHeartRate;

  SensorStats({
    required this.period,
    this.avgSpo2,
    this.minSpo2,
    this.avgHeartRate,
    this.maxHeartRate,
  });

  factory SensorStats.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] ?? {};
    return SensorStats(
      period: json['period'] ?? '24h',
      avgSpo2: stats['avg_spo2']?.toDouble(),
      minSpo2: stats['min_spo2'],
      avgHeartRate: stats['avg_heart_rate']?.toDouble(),
      maxHeartRate: stats['max_heart_rate'],
    );
  }
}