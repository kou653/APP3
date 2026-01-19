import 'package:flutter/material.dart';

class PredictionResult {
  final Prediction prediction;
  final PredictionMessage message;
  final List<PredictionFactor> factors;
  final List<String> recommendations;
  final PredictionEnvironment environment;
  final PredictionSensors sensors;
  final UiData uiData;
  final PredictionMetadata metadata;

  PredictionResult({
    required this.prediction,
    required this.message,
    required this.factors,
    required this.recommendations,
    required this.environment,
    required this.sensors,
    required this.uiData,
    required this.metadata,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    var factorsList = <PredictionFactor>[];
    if (json['factors'] is List) {
      factorsList = (json['factors'] as List)
          .map((factor) => PredictionFactor.fromJson(factor))
          .toList();
    }

    var recommendationsList = <String>[];
    if (json['recommendations'] is List) {
      recommendationsList = List<String>.from(json['recommendations']);
    }

    return PredictionResult(
      prediction: Prediction.fromJson(json['prediction']),
      message: PredictionMessage.fromJson(json['message']),
      factors: factorsList,
      recommendations: recommendationsList,
      environment: PredictionEnvironment.fromJson(json['environment']),
      sensors: PredictionSensors.fromJson(json['sensors']),
      uiData: UiData.fromJson(json['ui_data']),
      metadata: PredictionMetadata.fromJson(json['metadata']),
    );
  }
}

class Prediction {
  final String riskLevel;
  final num riskScore;
  final String riskColor;
  final List<String> riskGradient;
  final String riskIcon;
  final num confidence;

  Prediction({
    required this.riskLevel,
    required this.riskScore,
    required this.riskColor,
    required this.riskGradient,
    required this.riskIcon,
    required this.confidence,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    var gradientList = <String>[];
    if (json['risk_gradient'] is List) {
      gradientList = List<String>.from(json['risk_gradient'].map((x) => x));
    }
    return Prediction(
      riskLevel: json['risk_level'],
      riskScore: json['risk_score'],
      riskColor: json['risk_color'],
      riskGradient: gradientList,
      riskIcon: json['risk_icon'],
      confidence: json['confidence'],
    );
  }
}

class PredictionMessage {
  final String title;
  final String subtitle;
  final String description;
  final String action;
  final String emoji;
  final String profile;

  PredictionMessage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.action,
    required this.emoji,
    required this.profile,
  });

  factory PredictionMessage.fromJson(Map<String, dynamic> json) {
    return PredictionMessage(
      title: json['title'],
      subtitle: json['subtitle'],
      description: json['description'],
      action: json['action'],
      emoji: json['emoji'],
      profile: json['profile'],
    );
  }
}

class PredictionFactor {
  final String factor;
  final num value;
  final double contributionPercent;
  final String status;
  final String message;

  PredictionFactor({
    required this.factor,
    required this.value,
    required this.contributionPercent,
    required this.status,
    required this.message,
  });

  factory PredictionFactor.fromJson(Map<String, dynamic> json) {
    return PredictionFactor(
      factor: json['factor'],
      value: json['value'],
      contributionPercent: json['contribution_percent']?.toDouble(),
      status: json['status'],
      message: json['message'],
    );
  }
}

class PredictionEnvironment {
  final WeatherPrediction weather;
  final AirQualityPrediction airQuality;
  final String location;

  PredictionEnvironment({
    required this.weather,
    required this.airQuality,
    required this.location,
  });

  factory PredictionEnvironment.fromJson(Map<String, dynamic> json) {
    return PredictionEnvironment(
      weather: WeatherPrediction.fromJson(json['weather']),
      airQuality: AirQualityPrediction.fromJson(json['air_quality']),
      location: json['location'],
    );
  }
}

class WeatherPrediction {
  final double temperature;
  final int humidity;
  final String description;
  final String icon;

  WeatherPrediction({
    required this.temperature,
    required this.humidity,
    required this.description,
    required this.icon,
  });

  factory WeatherPrediction.fromJson(Map<String, dynamic> json) {
    return WeatherPrediction(
      temperature: json['temperature']?.toDouble(),
      humidity: json['humidity'],
      description: json['description'],
      icon: json['icon'],
    );
  }
}

class AirQualityPrediction {
  final int aqi;
  final String level;
  final int pollen;

  AirQualityPrediction({
    required this.aqi,
    required this.level,
    required this.pollen,
  });

  factory AirQualityPrediction.fromJson(Map<String, dynamic> json) {
    return AirQualityPrediction(
      aqi: json['aqi'],
      level: json['level'],
      pollen: json['pollen'],
    );
  }
}

class PredictionSensors {
  final int spo2;
  final int heartRate;
  final int respiratoryRate;
  final String source;

  PredictionSensors({
    required this.spo2,
    required this.heartRate,
    required this.respiratoryRate,
    required this.source,
  });

  factory PredictionSensors.fromJson(Map<String, dynamic> json) {
    return PredictionSensors(
      spo2: json['spo2'],
      heartRate: json['heart_rate'],
      respiratoryRate: json['respiratory_rate'],
      source: json['source'],
    );
  }
}

class UiData {
  final String cardColor;
  final String textColor;
  final String animation;
  final String soundAlert;

  UiData({
    required this.cardColor,
    required this.textColor,
    required this.animation,
    required this.soundAlert,
  });

  factory UiData.fromJson(Map<String, dynamic> json) {
    return UiData(
      cardColor: json['card_color'],
      textColor: json['text_color'],
      animation: json['animation'],
      soundAlert: json['sound_alert'],
    );
  }
}

class PredictionMetadata {
  final String userId;
  final String profile;
  final DateTime timestamp;
  final String apiVersion;

  PredictionMetadata({
    required this.userId,
    required this.profile,
    required this.timestamp,
    required this.apiVersion,
  });

  factory PredictionMetadata.fromJson(Map<String, dynamic> json) {
    return PredictionMetadata(
      userId: json['user_id'],
      profile: json['profile'],
      timestamp: DateTime.parse(json['timestamp']),
      apiVersion: json['api_version'],
    );
  }
}
