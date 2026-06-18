import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/city_model.dart';
import 'package:flutter_application_1/pages/weather_page.dart';
import 'package:flutter_application_1/services/city_service.dart';
import 'package:flutter_application_1/services/location_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _formKey = GlobalKey<FormState>();
  List<CityModel> _cities = [];
  CityModel? _selectedCity;
  String _uf = "";
  bool _isLoading = false;
  bool _isLocating = false;

  final List<String> estados = [
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA',
    'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN',
    'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO',
  ];

  Future<void> _fetchCities(String uf) async {
    setState(() {
      _isLoading = true;
      _cities = [];
      _selectedCity = null;
    });

    try {
      final cities = await CityService.fetchCityByState(uf);
      setState(() => _cities = cities);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao buscar cidades. Tente novamente.')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _buscar() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WeatherPage(city: _selectedCity!),
        ),
      );
    }
  }

  Future<void> _usarLocalizacao() async {
    setState(() => _isLocating = true);
    try {
      final location = await LocationService.getCurrentLocation();
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WeatherPage.fromLocation(
            locationName: location.cityName,
            lat: location.lat,
            lon: location.lon,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Previsão do Tempo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Estado (UF)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.map),
                ),
                items: estados
                    .map((uf) => DropdownMenuItem(value: uf, child: Text(uf)))
                    .toList(),
                onChanged: (uf) {
                  if (uf == null) return;
                  setState(() => _uf = uf);
                  _fetchCities(uf);
                },
                validator: (v) => v == null ? 'Selecione um estado' : null,
              ),
              const SizedBox(height: 12),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Autocomplete<CityModel>(
                  displayStringForOption: (city) => city.nome ?? '',
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) return _cities;
                    return _cities.where(
                      (city) => (city.nome ?? '').toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      ),
                    );
                  },
                  onSelected: (city) => setState(() => _selectedCity = city),
                  fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'Cidade',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.location_city),
                        hintText: _uf.isEmpty
                            ? 'Selecione um estado primeiro'
                            : 'Digite o nome da cidade',
                      ),
                      enabled: _cities.isNotEmpty,
                      validator: (_) =>
                          _selectedCity == null ? 'Selecione uma cidade' : null,
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final city = options.elementAt(index);
                              return ListTile(
                                title: Text(city.nome ?? ''),
                                onTap: () => onSelected(city),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: (_isLoading || _isLocating) ? null : _buscar,
                icon: const Icon(Icons.search),
                label: const Text('Ver Previsão'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: (_isLoading || _isLocating) ? null : _usarLocalizacao,
                icon: _isLocating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: Text(_isLocating ? 'Obtendo localização...' : 'Usar minha localização'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
