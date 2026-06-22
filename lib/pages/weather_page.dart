import 'package:flutter/material.dart';
import 'package:flutter_application_1/database/database_helper.dart';
import 'package:flutter_application_1/models/city_model.dart';
import 'package:flutter_application_1/models/weather_model.dart';
import 'package:flutter_application_1/services/weather_service.dart';

class WeatherPage extends StatefulWidget {
  final CityModel? city;
  final String? locationName;
  final double? lat;
  final double? lon;

  const WeatherPage({super.key, this.city})
      : locationName = null,
        lat = null,
        lon = null;

  const WeatherPage.fromLocation({
    super.key,
    required this.locationName,
    required this.lat,
    required this.lon,
  }) : city = null;

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  WeatherModel? _weather;
  bool _isLoading = true;
  bool _isOffline = false;
  String? _error;

  String get _title => widget.city?.nome ?? widget.locationName ?? '';

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _isOffline = false;
    });
    try {
      final WeatherResult result;
      if (widget.lat != null && widget.lon != null) {
        result = await WeatherService.fetchWeatherByCoords(widget.lat!, widget.lon!);
      } else {
        result = await WeatherService.fetchWeather(widget.city?.nome ?? '');
      }

      await DatabaseHelper.saveWeather(result.lat, result.lon, result.weather);

      setState(() {
        _weather = result.weather;
        _isLoading = false;
      });
    } catch (_) {
      final cached = await _loadFromCache();
      if (cached != null) {
        setState(() {
          _weather = cached;
          _isOffline = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Sem conexão e sem dados em cache para esta localização.';
          _isLoading = false;
        });
      }
    }
  }

  Future<WeatherModel?> _loadFromCache() async {
    final lat = widget.lat;
    final lon = widget.lon;
    if (lat != null && lon != null) {
      return DatabaseHelper.getCachedWeather(lat, lon);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWeather,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Buscando previsão do tempo...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Não foi possível buscar o clima',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadWeather,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final weather = _weather!;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          child: Column(
            children: [
              if (_isOffline)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wifi_off, size: 16, color: Colors.white),
                      SizedBox(width: 6),
                      Text('Dados em cache — sem conexão', style: TextStyle(color: Colors.white, fontSize: 13)),
                    ],
                  ),
                ),
              Text(
                weather.icon,
                style: const TextStyle(fontSize: 96),
              ),
              const SizedBox(height: 16),
              Text(
                '${weather.temperature.toStringAsFixed(1)}°C',
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                weather.description,
                style: const TextStyle(fontSize: 22, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                'Sensação: ${weather.apparentTemperature.toStringAsFixed(1)}°C',
                style: const TextStyle(fontSize: 16, color: Colors.white60),
              ),
              const SizedBox(height: 40),
              Card(
                color: Colors.white.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _InfoTile(
                            icon: Icons.air,
                            label: 'Vento',
                            value: '${weather.windSpeed.toStringAsFixed(1)} km/h',
                          ),
                          _InfoTile(
                            icon: Icons.water_drop,
                            label: 'Umidade',
                            value: '${weather.humidity}%',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _InfoTile(
                            icon: Icons.arrow_downward,
                            label: 'Mínima',
                            value: '${weather.tempMin.toStringAsFixed(1)}°C',
                          ),
                          _InfoTile(
                            icon: Icons.arrow_upward,
                            label: 'Máxima',
                            value: '${weather.tempMax.toStringAsFixed(1)}°C',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
