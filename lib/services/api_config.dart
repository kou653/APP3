class ApiConfig {
  static const String baseUrl = "https://respira-backend.onrender.com/";

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
