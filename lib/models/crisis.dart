// Fichier : /lib/models/crisis.dart

/// Énumération pour la sévérité d'une crise
enum CrisisSeverity {
  light,    // Légère
  moderate, // Modérée
  severe,   // Grave
}

/// Modèle pour une crise asthmatique
class Crisis {
  final int? id;
  final DateTime startTime;
  final DateTime? endTime;
  final int? durationMinutes;
  final int? minSpo2;
  final int? maxHeartRate;
  final String triggerFactor; // Exercice, Pollution, Pollen, Allergie, etc.
  final CrisisSeverity severity;
  final String? notes;
  final bool? treatedWithInhaler;
  final String? inhalerType;
  final DateTime? createdAt;

  Crisis({
    this.id,
    required this.startTime,
    this.endTime,
    this.durationMinutes,
    this.minSpo2,
    this.maxHeartRate,
    required this.triggerFactor,
    required this.severity,
    this.notes,
    this.treatedWithInhaler,
    this.inhalerType,
    this.createdAt,
  });

  /// Créer depuis JSON (réponse API)
  factory Crisis.fromJson(Map<String, dynamic> json) {
    // Parser la sévérité
    CrisisSeverity severity = CrisisSeverity.moderate;
    final severityStr = json['severity']?.toString().toUpperCase(); // Changed to toUpperCase()
    switch (severityStr) {
      case 'LIGHT': // Matched with uppercase
        severity = CrisisSeverity.light;
        break;
      case 'MODERATE': // Matched with uppercase
        severity = CrisisSeverity.moderate;
        break;
      case 'SEVERE': // Matched with uppercase
        severity = CrisisSeverity.severe;
        break;
    }

    // Calculer la durée en minutes si nécessaire
    int? durationMinutes = json['duration_minutes'];
    if (durationMinutes == null && json['start_time'] != null && json['end_time'] != null) {
      final start = DateTime.parse(json['start_time']);
      final end = DateTime.parse(json['end_time']);
      durationMinutes = end.difference(start).inMinutes;
    }

    return Crisis(
      id: json['id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      durationMinutes: durationMinutes,
      minSpo2: json['min_spo2'],
      maxHeartRate: json['max_heart_rate'],
      triggerFactor: json['trigger_factor'] ?? 'Inconnu',
      severity: severity,
      notes: json['notes'],
      treatedWithInhaler: json['treated_with_inhaler'],
      inhalerType: json['inhaler_type'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'duration_minutes': durationMinutes,
      'min_spo2': minSpo2,
      'max_heart_rate': maxHeartRate,
      'trigger_factor': triggerFactor,
      'severity': severityToString,
      'notes': notes,
      'treated_with_inhaler': treatedWithInhaler,
      'inhaler_type': inhalerType,
    };
  }

  /// Obtenir la sévérité en français
  String get severityFr {
    switch (severity) {
      case CrisisSeverity.light:
        return 'légère';
      case CrisisSeverity.moderate:
        return 'modérée';
      case CrisisSeverity.severe:
        return 'grave';
    }
  }

  /// Obtenir la sévérité en string
  String get severityToString {
    switch (severity) {
      case CrisisSeverity.light:
        return 'light';
      case CrisisSeverity.moderate:
        return 'moderate';
      case CrisisSeverity.severe:
        return 'severe';
    }
  }

  /// Formatter la date et l'heure
  String get formattedDateTime {
    final day = startTime.day;
    final month = _getMonthName(startTime.month);
    final hour = startTime.hour.toString().padLeft(2, '0');
    final minute = startTime.minute.toString().padLeft(2, '0');
    return '$day $month à $hour:$minute';
  }

  /// Formatter la durée
  String get formattedDuration {
    if (durationMinutes == null) return 'N/A';
    return '$durationMinutes minutes';
  }

  /// Formatter le SpO2 minimum
  String get formattedMinSpo2 {
    if (minSpo2 == null) return 'N/A';
    return '$minSpo2%';
  }

  /// Temps écoulé depuis la crise
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(startTime);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 30) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return 'Il y a ${(difference.inDays / 30).toStringAsFixed(1)}m';
    }
  }

  /// Copier la crise avec des modifications
  Crisis copyWith({
    int? id,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    int? minSpo2,
    int? maxHeartRate,
    String? triggerFactor,
    CrisisSeverity? severity,
    String? notes,
    bool? treatedWithInhaler,
    String? inhalerType,
    DateTime? createdAt,
  }) {
    return Crisis(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      minSpo2: minSpo2 ?? this.minSpo2,
      maxHeartRate: maxHeartRate ?? this.maxHeartRate,
      triggerFactor: triggerFactor ?? this.triggerFactor,
      severity: severity ?? this.severity,
      notes: notes ?? this.notes,
      treatedWithInhaler: treatedWithInhaler ?? this.treatedWithInhaler,
      inhalerType: inhalerType ?? this.inhalerType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Obtenir le nom du mois en français
  static String _getMonthName(int month) {
    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return months[month - 1];
  }
}

/// Modèle pour les statistiques de crises
class CrisisStats {
  final int totalCrises;
  final int crisisThisMonth;
  final int crisisLastMonth;
  final int daysWithoutCrisis;
  final String mostCommonTrigger;
  final double? riskReduction;
  final List<MonthlyData> monthlyCrisisData;

  CrisisStats({
    required this.totalCrises,
    required this.crisisThisMonth,
    required this.crisisLastMonth,
    required this.daysWithoutCrisis,
    required this.mostCommonTrigger,
    this.riskReduction,
    required this.monthlyCrisisData,
  });

  /// Créer depuis JSON
  factory CrisisStats.fromJson(Map<String, dynamic> json) {
    List<MonthlyData> monthlyList = [];
    if (json['monthly_data'] is List) {
      final monthlyData = json['monthly_data'] as List<dynamic>? ?? [];
      monthlyList = monthlyData
          .map((item) => MonthlyData.fromJson(item))
          .toList();
    }

    return CrisisStats(
      totalCrises: json['total_crises'] ?? 0,
      crisisThisMonth: json['crisis_this_month'] ?? 0,
      crisisLastMonth: json['crisis_last_month'] ?? 0,
      daysWithoutCrisis: json['days_without_crisis'] ?? 0,
      mostCommonTrigger: json['most_common_trigger'] ?? 'Inconnu',
      riskReduction: json['risk_reduction']?.toDouble(),
      monthlyCrisisData: monthlyList,
    );
  }

  /// Calcul du changement en pourcentage
  String get percentageChange {
    if (crisisLastMonth == 0) {
      return crisisThisMonth == 0 ? '0%' : '+${crisisThisMonth * 100}%';
    }
    final change = ((crisisThisMonth - crisisLastMonth) / crisisLastMonth * 100).toStringAsFixed(0);
    final prefix = int.parse(change) >= 0 ? '+' : '';
    return '$prefix$change%';
  }
}

/// Modèle pour les données mensuelles
class MonthlyData {
  final String month;
  final int count;
  final int monthIndex;

  MonthlyData({
    required this.month,
    required this.count,
    required this.monthIndex,
  });

  factory MonthlyData.fromJson(Map<String, dynamic> json) {
    return MonthlyData(
      month: json['month'] ?? '',
      count: json['count'] ?? 0,
      monthIndex: json['month_index'] ?? 0,
    );
  }
}

/// Modèle pour les patterns détectés
class CrisisPattern {
  final String description;
  final double percentage;
  final String icon;

  CrisisPattern({
    required this.description,
    required this.percentage,
    required this.icon,
  });

  factory CrisisPattern.fromJson(Map<String, dynamic> json) {
    return CrisisPattern(
      description: json['description'] ?? '',
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      icon: json['icon'] ?? '📊',
    );
  }
}