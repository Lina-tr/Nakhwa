import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:nakhwa/config/config.dart';
import 'package:intl/intl.dart';

class WeatherServicePage extends StatefulWidget {
  const WeatherServicePage({super.key});

  @override
  State<WeatherServicePage> createState() => _WeatherServicePageState();
}

class _WeatherServicePageState extends State<WeatherServicePage> {
  Map<String, dynamic> _weatherData = {
    'current': {
      'temp': '--',
      'description': 'غير متوفر',
      'humidity': '--',
      'windSpeed': '--',
      'icon': '100',
      'feelsLike': '--',
    },
    'hourly': [],
    'daily': [],
    'city': 'غير متوفر',
  };
  bool _isLoading = false;
  String _errorMessage = '';
  final String _apiKey =
      '02baf7b268b041c4b15180559251807'; // Provided WeatherAPI key

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          setState(() {
            _errorMessage = 'تم رفض إذن الموقع';
            _isLoading = false;
          });
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition();
      final city = await _getCityName(position.latitude, position.longitude);

      final url = Uri.parse(
        'http://api.weatherapi.com/v1/forecast.json?key=$_apiKey&q=${position.latitude},${position.longitude}&days=5&aqi=yes&lang=ar',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _weatherData = {
            'current': {
              'temp': data['current']['temp_c'].toStringAsFixed(0),
              'description': data['current']['condition']['text'],
              'humidity': data['current']['humidity'].toString(),
              'windSpeed': data['current']['wind_kph'].toString(),
              'icon': data['current']['condition']['code'].toString(),
              'feelsLike': data['current']['feelslike_c'].toStringAsFixed(0),
            },
            'hourly': data['forecast']['forecastday'][0]['hour']
                .take(6)
                .map(
                  (h) => {
                    'time': DateFormat(
                      'HH:mm',
                    ).format(DateTime.parse(h['time'])),
                    'temp': h['temp_c'].toStringAsFixed(0),
                    'icon': h['condition']['code'].toString(),
                  },
                )
                .toList(),
            'daily': data['forecast']['forecastday']
                .take(5)
                .map(
                  (d) => {
                    'day': DateFormat(
                      'EEEE',
                      'ar',
                    ).format(DateTime.parse(d['date'])),
                    'tempMin': d['day']['mintemp_c'].toStringAsFixed(0),
                    'tempMax': d['day']['maxtemp_c'].toStringAsFixed(0),
                    'icon': d['day']['condition']['code'].toString(),
                  },
                )
                .toList(),
            'city': city,
          };
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'فشل في جلب بيانات الطقس';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ: $e';
        _isLoading = false;
      });
    }
  }

  Future<String?> _getCityName(double lat, double lon) async {
    try {
      final res = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json&zoom=10',
        ),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['address']['city'] ??
            data['address']['town'] ??
            data['address']['village'] ??
            'غير متوفر';
      }
    } catch (_) {}
    return 'غير متوفر';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Nakhwa.background,
      appBar: AppBar(
        title: const Text('الطقس', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Nakhwa.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _fetchWeather();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white24, height: 1),
        ),
      ),
      body: _isLoading == true
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    Text(
                      'الطقس في ${_weatherData['city']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      color: Colors.white.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_weatherData['current']['temp']}° مئوية',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _weatherData['current']['description'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'الإحساس: ${_weatherData['current']['feelsLike']}° مئوية',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'الرطوبة: ${_weatherData['current']['humidity']}% | الرياح: ${_weatherData['current']['windSpeed']} كم/س',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Image.network(
                              'https://cdn.weatherapi.com/weather/64x64/day/${_weatherData['current']['icon']}.png',
                              width: 64,
                              height: 64,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.cloud,
                                color: Colors.white,
                                size: 64,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'توقعات كل ساعة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _weatherData['hourly'].length,
                        itemBuilder: (context, index) {
                          final hourly = _weatherData['hourly'][index];
                          return Container(
                            width: 100,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  hourly['time'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                Image.network(
                                  'https://cdn.weatherapi.com/weather/64x64/day/${hourly['icon']}.png',
                                  width: 40,
                                  height: 40,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.cloud,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                                Text(
                                  '${hourly['temp']}° مئوية',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'توقعات الأيام القادمة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: _weatherData['daily'].map<Widget>((daily) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Image.network(
                                'https://cdn.weatherapi.com/weather/64x64/day/${daily['icon']}.png',
                                width: 40,
                                height: 40,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.cloud,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  daily['day'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Text(
                                '${daily['tempMax']}° / ${daily['tempMin']}°',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
