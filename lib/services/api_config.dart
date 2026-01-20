class ApiConfig {
  static const String baseUrl = "https://respira-backend.onrender.com/";
  static const String mlBaseUrl = "https://ml-respir-ai.onrender.com/api/v1";
  // ENVIRONNEMENT
  static const String weatherCurrent =
      "$baseUrl/environment/weather/current/";
  static const String weatherList =
      "$baseUrl/environment/weather/";
  static const String airQualityCurrent =
      "$baseUrl/environment/air-quality/current/";

  // CAPTEURS / BRACELETS
  static const String devices =
      "$baseUrl/sensors/devices/";
}
