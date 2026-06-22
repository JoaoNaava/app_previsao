class WeatherModel {
  final double temperature;
  final double apparentTemperature;
  final double windSpeed;
  final int humidity;
  final int weatherCode;
  final double tempMin;
  final double tempMax;

  WeatherModel({
    required this.temperature,
    required this.apparentTemperature,
    required this.windSpeed,
    required this.humidity,
    required this.weatherCode,
    required this.tempMin,
    required this.tempMax,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    final daily = json['daily'];
    return WeatherModel(
      temperature: (current['temperature_2m'] as num).toDouble(),
      apparentTemperature: (current['apparent_temperature'] as num).toDouble(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      weatherCode: current['weather_code'] as int,
      tempMin: (daily['temperature_2m_min'][0] as num).toDouble(),
      tempMax: (daily['temperature_2m_max'][0] as num).toDouble(),
    );
  }

  factory WeatherModel.fromMap(Map<String, dynamic> map) {
    return WeatherModel(
      temperature: map['temperature'] as double,
      apparentTemperature: map['apparent_temperature'] as double,
      windSpeed: map['wind_speed'] as double,
      humidity: map['humidity'] as int,
      weatherCode: map['weather_code'] as int,
      tempMin: map['temp_min'] as double,
      tempMax: map['temp_max'] as double,
    );
  }

  Map<String, dynamic> toMap(double lat, double lon) => {
        'lat': lat,
        'lon': lon,
        'temperature': temperature,
        'apparent_temperature': apparentTemperature,
        'wind_speed': windSpeed,
        'humidity': humidity,
        'weather_code': weatherCode,
        'temp_min': tempMin,
        'temp_max': tempMax,
        'updated_at': DateTime.now().toIso8601String(),
      };

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
