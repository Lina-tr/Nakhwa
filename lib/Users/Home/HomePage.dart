import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:nakhwa/config/config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nakhwa/Widgets/email_service.dart';
import 'package:xml/xml.dart';

class NakhwaAlertPage extends StatefulWidget {
  const NakhwaAlertPage({super.key});
  @override
  State<NakhwaAlertPage> createState() => _NakhwaAlertPageState();
}

class _NakhwaAlertPageState extends State<NakhwaAlertPage> {
  LatLng? _currentLatLng;
  GoogleMapController? _mapController;
  Map<String, String>? _alert;
  final Map<String, dynamic> _weatherData = {
    'current': {
      'temp': '--',
      'description': 'غير متوفر',
      'humidity': '--',
      'windSpeed': '--',
      'icon': '100',
    },
    'hourly': [],
    'city': 'غير متوفر',
  };
  final String _apiKey = '02baf7b268b041c4b15180559251807';

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.always ||
          perm == LocationPermission.whileInUse) {
        final pos = await Geolocator.getCurrentPosition();
        setState(() {
          _currentLatLng = LatLng(pos.latitude, pos.longitude);
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_currentLatLng!, 13),
        );
        await _fetchWeather(pos.latitude, pos.longitude);
        await _fetchAlerts();
      }
    } catch (_) {}
  }

  Future<void> _fetchWeather(double lat, double lon) async {
    try {
      final res = await http.get(
        Uri.parse(
          'http://api.weatherapi.com/v1/forecast.json?key=$_apiKey&q=$lat,$lon&days=2&lang=ar',
        ),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final current = data['current'];

        final forecast = data['forecast']['forecastday'];
        setState(() {
          _weatherData['current'] = {
            'temp': current['temp_c'].toStringAsFixed(0),
            'description': current['condition']['text'],
            'humidity': current['humidity'].toString(),
            'windSpeed': current['wind_kph'].toString(),
            'icon': current['condition']['code'].toString(),
          };
          _weatherData['city'] = data['location']['name'];
          _weatherData['hourly'] = [];
          final now = DateTime.now();
          final future = now.add(Duration(hours: 24));
          for (var day in forecast) {
            for (var hour in day['hour']) {
              final hourTime = DateTime.parse(hour['time']);
              if (hourTime.isAfter(now) && hourTime.isBefore(future)) {
                _weatherData['hourly'].add({
                  'time': hourTime,
                  'condition_text': hour['condition']['text'],
                  'condition_code': hour['condition']['code'],
                });
              }
            }
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchAlerts() async {
    Map<String, String>? sel;
    if (_weatherData['hourly'] != null) {
      for (var hour in _weatherData['hourly']) {
        final text = hour['condition_text'];
        if (text.contains('مطر') ||
            text.contains('عاصفة') ||
            text.contains('فيضان') ||
            text.contains('رعد') ||
            text.contains('ثلج') ||
            text.contains('برد')) {
          sel = {
            'text': '⚠️ توقع $text في ${_weatherData['city']}',
            'time': hour['time'].toIso8601String().substring(0, 16),
            'type': 'weather',
          };
          break;
        }
      }
    }

    if (sel == null && _currentLatLng != null) {
      try {
        final res = await http.get(
          Uri.parse(
            'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson',
          ),
        );
        if (res.statusCode == 200) {
          final feats = jsonDecode(res.body)['features'] as List;
          for (var f in feats) {
            final mag = f['properties']['mag'];
            final place = f['properties']['place'];
            final time = DateTime.fromMillisecondsSinceEpoch(
              f['properties']['time'],
            );
            final coords = f['geometry']['coordinates'] as List;
            final distance =
                Geolocator.distanceBetween(
                  _currentLatLng!.latitude,
                  _currentLatLng!.longitude,
                  coords[1],
                  coords[0],
                ) /
                1000; // Convert to kilometers
            if (distance < 500) {
              sel = {
                'text': '🌎 زلزال قوته $mag قرب $place',
                'time': time.toIso8601String().substring(0, 16),
                'type': 'earthquake',
              };
              break;
            }
          }
        }
      } catch (_) {}
    }

    setState(() => _alert = sel);
  }

  Future<void> _sendSOS() async {
    final user = FirebaseAuth.instance.currentUser;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    final data = doc.data();

    final emergencyEmail = data?['emergencyEmail'] ?? '';
    final name = data?['fullName'] ?? '';
    final Map<String, dynamic>? healthData =
        (data?['healthData'] as Map<String, dynamic>?);
    String locationText;
    String mapLink = '';

    if (_currentLatLng != null) {
      final lat = _currentLatLng!.latitude.toStringAsFixed(4);
      final lng = _currentLatLng!.longitude.toStringAsFixed(4);
      locationText = 'الموقع الحالي: $lat, $lng';
      mapLink =
          '\nرابط الموقع على الخريطة: https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    } else {
      locationText = 'الموقع غير متوفر حالياً';
    }

    if (emergencyEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد بريد إلكتروني للطوارئ مسجل')),
      );
      return;
    }

    final StringBuffer body = StringBuffer('قام $name بطلب المساعدة.\n\n');
    body.write('$locationText$mapLink');
    if (healthData != null && healthData.isNotEmpty) {
      body.write('\n\nالمعلومات الصحية:\n');
      healthData.forEach((k, v) => body.write('$k $v\n'));
    }

    await EmailService.sendEmail(
      recipients: [emergencyEmail, Nakhwa.adminEmail],
      subject: 'نداء استغاثة عاجل (SOS)',
      body: body.toString(),
    );

    // Save SOS request to Firestore
    await FirebaseFirestore.instance.collection('SOS').add({
      'userId': user.uid,
      'userName': name,
      'emergencyEmail': emergencyEmail,
      if (_currentLatLng != null)
        'location': {
          'lat': _currentLatLng!.latitude,
          'lng': _currentLatLng!.longitude,
        },
      if (healthData != null) 'healthData': healthData,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ تم إرسال نداء الاستغاثة بنجاح')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Nakhwa.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _sendSOS();
        },
        backgroundColor: Colors.redAccent,
        label: const Text(
          'SOS',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مرحبًا في ${_weatherData['city']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
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
                                'الرطوبة ${_weatherData['current']['humidity']}% | الرياح ${_weatherData['current']['windSpeed']} كم/س',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
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
                  const SizedBox(height: 20),
                  if (_alert != null)
                    Card(
                      color: _alert!['type'] == 'weather'
                          ? const Color(0xFFEF5350)
                          : _alert!['type'] == 'earthquake'
                          ? const Color(0xFFFFA726)
                          : const Color(0xFF29B6F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _alert!['text']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _alert!['time']!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    const Text(
                      'لا توجد تنبيهات حالياً',
                      style: TextStyle(color: Colors.white70),
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 220,
                    child: _currentLatLng == null
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: GoogleMap(
                              onMapCreated: (c) => _mapController = c,
                              initialCameraPosition: CameraPosition(
                                target: _currentLatLng!,
                                zoom: 13,
                              ),
                              myLocationEnabled: true,
                              markers: {
                                Marker(
                                  markerId: const MarkerId('me'),
                                  position: _currentLatLng!,
                                  infoWindow: const InfoWindow(
                                    title: 'موقعي الحالي',
                                  ),
                                ),
                              },
                              zoomControlsEnabled: false,
                              compassEnabled: true,
                            ),
                          ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
