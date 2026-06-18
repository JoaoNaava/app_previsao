import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/models/weather_model.dart';

class WeatherService {
  static Future<WeatherModel> fetchWeather(String cityName) async {
    final geoUrl = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(cityName)}&count=1&language=pt&format=json',
    );

    final geoResponse = await http.get(geoUrl);
    if (geoResponse.statusCode != 200) {
      throw Exception('Erro ao geocodificar cidade');
    }

    final geoJson = jsonDecode(geoResponse.body);
    final results = geoJson['results'];
    if (results == null || results.isEmpty) {
      throw Exception('Cidade não encontrada no serviço de clima');
    }

    return fetchWeatherByCoords(results[0]['latitude'], results[0]['longitude']);
  }

  static Future<WeatherModel> fetchWeatherByCoords(double lat, double lon) async {
    final weatherUrl = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat&longitude=$lon'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m',
    );

    final weatherResponse = await http.get(weatherUrl);
    if (weatherResponse.statusCode != 200) {
      throw Exception('Erro ao buscar clima');
    }

    return WeatherModel.fromJson(jsonDecode(weatherResponse.body));
  }
}
