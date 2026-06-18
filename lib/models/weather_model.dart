class WeatherModel {
  final double temperature;
  final double apparentTemperature;
  final double windSpeed;
  final int humidity;
  final int weatherCode;

  WeatherModel({
    required this.temperature,
    required this.apparentTemperature,
    required this.windSpeed,
    required this.humidity,
    required this.weatherCode,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    return WeatherModel(
      temperature: (current['temperature_2m'] as num).toDouble(),
      apparentTemperature: (current['apparent_temperature'] as num).toDouble(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      weatherCode: current['weather_code'] as int,
    );
  }

  String get description {
    if (weatherCode == 0) return 'Céu limpo';
    if (weatherCode <= 2) return 'Parcialmente nublado';
    if (weatherCode == 3) return 'Nublado';
    if (weatherCode <= 49) return 'Neblina';
    if (weatherCode <= 67) return 'Chuva';
    if (weatherCode <= 77) return 'Neve';
    if (weatherCode <= 82) return 'Pancadas de chuva';
    if (weatherCode <= 99) return 'Tempestade';
    return 'Desconhecido';
  }

  String get icon {
    if (weatherCode == 0) return '☀️';
    if (weatherCode <= 2) return '⛅';
    if (weatherCode == 3) return '☁️';
    if (weatherCode <= 49) return '🌫️';
    if (weatherCode <= 67) return '🌧️';
    if (weatherCode <= 77) return '❄️';
    if (weatherCode <= 82) return '🌦️';
    if (weatherCode <= 99) return '⛈️';
    return '🌡️';
  }
}
