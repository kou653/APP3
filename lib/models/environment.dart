// Fichier : /lib/models/environment.dart

import 'package:flutter/material.dart';

/// Modèle pour la qualité de l'air
class AirQuality {
  final String city;
  final String country;
  final int aqi;
  final String qualityLevel;
  final String mainPollutant;
  final Map<String, double> pollutants;
  final List<String> healthRecommendations;
  final DateTime timestamp;

  AirQuality({
    required this.city,
    required this.country,
    required this.aqi,
    required this.qualityLevel,
    required this.mainPollutant,
    required this.pollutants,
    required this.healthRecommendations,
    required this.timestamp,
  });

  factory AirQuality.fromJson(Map<String, dynamic> json) {
    // Parser les polluants
    final pollutantsData = json['pollutants'] as Map<String, dynamic>? ?? {};
    final pollutants = pollutantsData.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );

    // Parser les recommandations
    final recommendations = json['health_recommendations'] as List<dynamic>? ?? [];
    
    return AirQuality(
      city: json['city'] ?? 'Inconnu',
      country: json['country'] ?? '',
      aqi: json['aqi'] ?? 0,
      qualityLevel: json['quality_level'] ?? 'Inconnu',
      mainPollutant: json['main_pollutant'] ?? 'pm25',
      pollutants: pollutants,
      healthRecommendations: recommendations.map((e) => e.toString()).toList(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  /// Niveau en français (déjà fourni par l'API)
  String get aqiLevelFr => qualityLevel;

  /// Couleur selon le niveau AQI
  Color get color {
    if (aqi <= 50) return const Color(0xFF4CAF50);      // Bon - Vert
    if (aqi <= 100) return const Color(0xFFFFC107);     // Modéré - Jaune
    if (aqi <= 150) return const Color(0xFFFF9800);     // Sensible - Orange
    if (aqi <= 200) return const Color(0xFFF44336);     // Mauvais - Rouge
    if (aqi <= 300) return const Color(0xFF9C27B0);     // Très mauvais - Violet
    return const Color(0xFF880E4F);                      // Dangereux - Marron
  }

  /// Affichage formaté
  String get display => 'Air (AQI $aqi)';

  /// PM2.5 formaté
  String get pm25Display {
    final pm25 = pollutants['pm25'];
    return pm25 != null ? '${pm25.toStringAsFixed(1)} μg/m³' : 'N/A';
  }

  /// PM10 formaté
  String get pm10Display {
    final pm10 = pollutants['pm10'];
    return pm10 != null ? '${pm10.toStringAsFixed(1)} μg/m³' : 'N/A';
  }
}

/// Modèle pour la météo
class Weather {
  final String city;
  final String country;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final String description;
  final String weatherMain;
  final double windSpeed;
  final int pressure;
  final int visibility;
  final DateTime timestamp;

  Weather({
    required this.city,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.description,
    required this.weatherMain,
    required this.windSpeed,
    required this.pressure,
    required this.visibility,
    required this.timestamp,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      city: json['city'] ?? 'Inconnu',
      country: json['country'] ?? '',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (json['feels_like'] as num?)?.toDouble() ?? 0.0,
      humidity: json['humidity'] ?? 0,
      description: json['description'] ?? '',
      weatherMain: json['weather_main'] ?? '',
      windSpeed: (json['wind_speed'] as num?)?.toDouble() ?? 0.0,
      pressure: json['pressure'] ?? 0,
      visibility: json['visibility'] ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  /// Température formatée
  String get temperatureDisplay => '${temperature.toStringAsFixed(1)}°C';

  /// Ressenti formaté
  String get feelsLikeDisplay => '${feelsLike.toStringAsFixed(1)}°C';

  /// Humidité formatée
  String get humidityDisplay => '$humidity%';

  /// Vent formaté
  String get windSpeedDisplay => '${windSpeed.toStringAsFixed(1)} m/s';

  /// Pression formatée
  String get pressureDisplay => '$pressure hPa';

  /// Visibilité formatée (en km)
  String get visibilityDisplay => '${(visibility / 1000).toStringAsFixed(1)} km';

  /// Icône selon le type de météo
  IconData get weatherIcon {
    switch (weatherMain.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.wb_cloudy;
      case 'rain':
      case 'drizzle':
        return Icons.umbrella;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'snow':
        return Icons.ac_unit;
      case 'mist':
      case 'fog':
        return Icons.cloud;
      default:
        return Icons.wb_cloudy;
    }
  }
}