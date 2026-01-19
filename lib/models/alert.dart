// Fichier : /lib/models/alert.dart

/// Énumération pour le niveau de risque
enum RiskLevel {
  low,      // RISQUE FAIBLE
  moderate, // RISQUE MODÉRÉ
  high,     // RISQUE ÉLEVÉ
  critical, // RISQUE CRITIQUE
}

/// Énumération pour le type d'alerte
enum AlertType {
  riskPrediction,    // Prédiction de risque
  airQuality,        // Qualité de l'air
  medication,        // Rappel médicament
  symptom,           // Symptômes détectés
}

/// Modèle pour une alerte
class Alert {
  final int id;
  final int userId;
  final int sensorDataId;
  final String alertType; // Matches API alert_type (e.g., "HIGH_POLLEN")
  final String severity;  // Matches API severity (e.g., "INFO")
  final String message;   // Matches API message
  final bool isRead;
  final DateTime createdAt;

  Alert({
    required this.id,
    required this.userId,
    required this.sensorDataId,
    required this.alertType,
    required this.severity,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  /// Créer depuis JSON (réponse API)
  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'],
      userId: json['user'],
      sensorDataId: json['sensor_data'],
      alertType: json['alert_type'],
      severity: json['severity'],
      message: json['message'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'sensor_data': sensorDataId,
      'alert_type': alertType,
      'severity': severity,
      'message': message,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Obtenir le niveau de risque en français (from severity)
  String get severityFr {
    switch (severity) {
      case 'INFO':
        return 'Information';
      case 'WARNING':
        return 'Avertissement';
      case 'CRITICAL':
        return 'Critique';
      default:
        return severity;
    }
  }

  // Client-side helper to convert API alertType string to a meaningful description
  String get alertTypeDescription {
    switch (alertType) {
      case 'LOW_SPO2':
        return 'SpO2 faible';
      case 'HIGH_RESPIRATORY_RATE':
        return 'Fréquence respiratoire élevée';
      case 'POOR_AIR_QUALITY':
        return 'Qualité d\'air dangereuse';
      case 'SMOKE_DETECTED':
        return 'Fumée détectée';
      case 'HIGH_POLLEN':
        return 'Pollen élevé';
      default:
        return alertType;
    }
  }

  /// Temps écoulé depuis l'alerte
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

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

  /// Icône selon le type
  String get iconEmoji {
    switch (alertType) {
      case 'LOW_SPO2':
        return '📉'; // or a relevant icon
      case 'HIGH_RESPIRATORY_RATE':
        return '💨'; // or a relevant icon
      case 'POOR_AIR_QUALITY':
        return '🌫️';
      case 'SMOKE_DETECTED':
        return '🔥';
      case 'HIGH_POLLEN':
        return '🌷';
      default:
        return '🔔';
    }
  }

  /// Copier l'alerte avec des modifications
  Alert copyWith({
    int? id,
    int? userId,
    int? sensorDataId,
    String? alertType,
    String? severity,
    String? message,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return Alert(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sensorDataId: sensorDataId ?? this.sensorDataId,
      alertType: alertType ?? this.alertType,
      severity: severity ?? this.severity,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}