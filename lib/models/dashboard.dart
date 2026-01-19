// Fichier : /lib/models/dashboard.dart

class DashboardResult {
  final CurrentRisk currentRisk;
  final DashboardSensors sensors;
  final DashboardEnvironment environment;
  final Statistics statistics;
  final List<dynamic> alerts;
  final List<QuickAction> quickActions;
  final DateTime timestamp;

  DashboardResult({
    required this.currentRisk,
    required this.sensors,
    required this.environment,
    required this.statistics,
    required this.alerts,
    required this.quickActions,
    required this.timestamp,
  });

  factory DashboardResult.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return DashboardResult(
        currentRisk: CurrentRisk.fromJson(null),
        sensors: DashboardSensors.fromJson(null),
        environment: DashboardEnvironment.fromJson(null),
        statistics: Statistics.fromJson(null),
        alerts: [],
        quickActions: [],
        timestamp: DateTime.now(),
      );
    }
    return DashboardResult(
      currentRisk: CurrentRisk.fromJson(json['current_risk']),
      sensors: DashboardSensors.fromJson(json['sensors']),
      environment: DashboardEnvironment.fromJson(json['environment']),
      statistics: Statistics.fromJson(json['statistics']),
      alerts: json['alerts'] ?? [],
      quickActions: (json['quick_actions'] as List? ?? [])
          .map((action) => QuickAction.fromJson(action))
          .toList(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }
}

class CurrentRisk {
  final String level;
  final double score;
  final String color;
  final List<String> gradient;
  final String icon;
  final String label;
  final DateTime updatedAt;

  CurrentRisk({
    required this.level,
    required this.score,
    required this.color,
    required this.gradient,
    required this.icon,
    required this.label,
    required this.updatedAt,
  });

  factory CurrentRisk.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return CurrentRisk(
        level: 'N/A',
        score: 0.0,
        color: '#808080',
        gradient: ['#BDBDBD', '#808080'],
        icon: 'help_outline',
        label: 'Indisponible',
        updatedAt: DateTime.now(),
      );
    }
    return CurrentRisk(
      level: json['level'] ?? 'N/A',
      score: (json['score'] ?? 0.0).toDouble(),
      color: json['color'] ?? '#808080',
      gradient: List<String>.from(json['gradient']?.map((x) => x) ?? ['#BDBDBD', '#808080']),
      icon: json['icon'] ?? 'help_outline',
      label: json['label'] ?? 'Indisponible',
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }
}

class DashboardSensors {
  final SensorValue spo2;
  final SensorValue heartRate;
  final SensorValue temperature;
  final SensorValue humidity;

  DashboardSensors({
    required this.spo2,
    required this.heartRate,
    required this.temperature,
    required this.humidity,
  });

  factory DashboardSensors.fromJson(Map<String, dynamic>? json) {
     if (json == null) {
      return DashboardSensors(
        spo2: SensorValue.fromJson(null),
        heartRate: SensorValue.fromJson(null),
        temperature: SensorValue.fromJson(null),
        humidity: SensorValue.fromJson(null),
      );
    }
    return DashboardSensors(
      spo2: SensorValue.fromJson(json['spo2']),
      heartRate: SensorValue.fromJson(json['heart_rate']),
      temperature: SensorValue.fromJson(json['temperature']),
      humidity: SensorValue.fromJson(json['humidity']),
    );
  }
}

class SensorValue {
  final num value;
  final String unit;
  final String status;
  final String icon;

  SensorValue({
    required this.value,
    required this.unit,
    required this.status,
    required this.icon,
  });

  factory SensorValue.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return SensorValue(value: 0, unit: '', status: 'N/A', icon: 'help_outline');
    }
    return SensorValue(
      value: json['value'] ?? 0,
      unit: json['unit'] ?? '',
      status: json['status'] ?? 'N/A',
      icon: json['icon'] ?? 'help_outline',
    );
  }
}

class DashboardEnvironment {
  final DashboardWeather weather;
  final DashboardAirQuality airQuality;

  DashboardEnvironment({required this.weather, required this.airQuality});

  factory DashboardEnvironment.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return DashboardEnvironment(
        weather: DashboardWeather.fromJson(null),
        airQuality: DashboardAirQuality.fromJson(null),
      );
    }
    return DashboardEnvironment(
      weather: DashboardWeather.fromJson(json['weather']),
      airQuality: DashboardAirQuality.fromJson(json['air_quality']),
    );
  }
}

class DashboardWeather {
  final num temperature;
  final num feelsLike;
  final num humidity;
  final String description;
  final String icon;
  final String city;

  DashboardWeather({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.description,
    required this.icon,
    required this.city,
  });

  factory DashboardWeather.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return DashboardWeather(
        temperature: 0,
        feelsLike: 0,
        humidity: 0,
        description: 'N/A',
        icon: 'help_outline',
        city: 'N/A',
      );
    }
    return DashboardWeather(
      temperature: json['temperature'] ?? 0,
      feelsLike: json['feels_like'] ?? 0,
      humidity: json['humidity'] ?? 0,
      description: json['description'] ?? 'N/A',
      icon: json['icon'] ?? 'help_outline',
      city: json['city'] ?? 'N/A',
    );
  }
}

class DashboardAirQuality {
  final int aqi;
  final String level;
  final int pollen;
  final String color;

  DashboardAirQuality({
    required this.aqi,
    required this.level,
    required this.pollen,
    required this.color,
  });

  factory DashboardAirQuality.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return DashboardAirQuality(
        aqi: 0,
        level: 'N/A',
        pollen: 0,
        color: '#808080',
      );
    }
    return DashboardAirQuality(
      aqi: json['aqi'] ?? 0,
      level: json['level'] ?? 'N/A',
      pollen: json['pollen'] ?? 0,
      color: json['color'] ?? '#808080',
    );
  }
}

class Statistics {
  final int predictionsToday;
  final String averageRisk;
  final int alertsCount;
  final dynamic lastHighRisk;

  Statistics({
    required this.predictionsToday,
    required this.averageRisk,
    required this.alertsCount,
    this.lastHighRisk,
  });

  factory Statistics.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Statistics(
        predictionsToday: 0,
        averageRisk: 'N/A',
        alertsCount: 0,
        lastHighRisk: null,
      );
    }
    return Statistics(
      predictionsToday: json['predictions_today'] ?? 0,
      averageRisk: json['average_risk'] ?? 'N/A',
      alertsCount: json['alerts_count'] ?? 0,
      lastHighRisk: json['last_high_risk'],
    );
  }
}

class QuickAction {
  final String id;
  final String label;
  final String icon;

  QuickAction({
    required this.id,
    required this.label,
    required this.icon,
  });

  factory QuickAction.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return QuickAction(id: '', label: 'N/A', icon: 'help_outline');
    }
    return QuickAction(
      id: json['id'] ?? '',
      label: json['label'] ?? 'N/A',
      icon: json['icon'] ?? 'help_outline',
    );
  }
}