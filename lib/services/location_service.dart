import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationResult {
  final double lat;
  final double lon;
  final String cityName;

  const LocationResult({
    required this.lat,
    required this.lon,
    required this.cityName,
  });
}

class LocationService {
  static Future<LocationResult> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Serviço de localização desativado. Ative o GPS e tente novamente.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permissão de localização negada permanentemente. Habilite nas configurações do dispositivo.');
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
    );

    final cityName = await _reversGeocode(position.latitude, position.longitude);

    return LocationResult(
      lat: position.latitude,
      lon: position.longitude,
      cityName: cityName,
    );
  }

  static Future<String> _reversGeocode(double lat, double lon) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&accept-language=pt',
      );
      final response = await http.get(url, headers: {'User-Agent': 'PrevisaoTempoApp/1.0'});

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final address = json['address'];
        return address['city'] ??
            address['town'] ??
            address['village'] ??
            address['municipality'] ??
            'Minha localização';
      }
    } catch (_) {}
    return 'Minha localização';
  }
}
