import 'package:flutter/material.dart';
import 'package:flutter_application_1/database/database_helper.dart';
import 'package:flutter_application_1/models/saved_location_model.dart';
import 'package:flutter_application_1/pages/home.dart';
import 'package:flutter_application_1/pages/weather_page.dart';
import 'package:flutter_application_1/services/location_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final location = await LocationService.getCurrentLocation();
      final saved = await DatabaseHelper.getSavedLocation();

      if (saved == null || saved.isDifferentFrom(location.lat, location.lon)) {
        await DatabaseHelper.saveOrUpdateLocation(SavedLocationModel(
          lat: location.lat,
          lon: location.lon,
          cityName: location.cityName,
          updatedAt: DateTime.now(),
        ));
      }

      if (!mounted) return;

      // Coloca Home como base da pilha e WeatherPage por cima
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Home()),
        (_) => false,
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => WeatherPage.fromLocation(
            locationName: location.cityName,
            lat: location.lat,
            lon: location.lon,
          ),
        ),
      );
    } catch (_) {
      // GPS indisponível ou permissão negada — abre Home para busca manual
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Home()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud, size: 80, color: Colors.blue),
            SizedBox(height: 24),
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Verificando localização...'),
          ],
        ),
      ),
    );
  }
}
