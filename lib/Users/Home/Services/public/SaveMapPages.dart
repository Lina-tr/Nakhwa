import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:nakhwa/config/config.dart';

class SafeMapPage extends StatefulWidget {
  const SafeMapPage({super.key});

  @override
  State<SafeMapPage> createState() => _SafeMapPageState();
}

class _SafeMapPageState extends State<SafeMapPage> {
  final Completer<GoogleMapController> _mapController = Completer();
  LatLng? _currentLocation;
  Set<Marker> _markers = {};

  static const List<String> _placeTypes = [
    'hospital',
    'fire_station',
    'police',
    'social_services',
  ];

  @override
  void initState() {
    super.initState();
    _initializeLocationAndPlaces();
  }

  Future<void> _initializeLocationAndPlaces() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.always ||
        perm == LocationPermission.whileInUse) {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final loc = LatLng(pos.latitude, pos.longitude);
      setState(() => _currentLocation = loc);
      _addUserMarker(loc);
      final controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newLatLngZoom(loc, 14));
      await _fetchNearbyPlaces(loc);
    }
  }

  void _addUserMarker(LatLng loc) {
    _markers.add(
      Marker(
        markerId: const MarkerId('me'),
        position: loc,
        infoWindow: const InfoWindow(title: 'موقعي الحالي'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );
  }

  Future<void> _fetchNearbyPlaces(LatLng loc) async {
    final key = Nakhwa.googleKey; // ensure valid API key is defined in config
    for (String type in _placeTypes) {
      final url =
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
          '?location=${loc.latitude},${loc.longitude}'
          '&radius=5000&type=$type&key=$key';
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        for (var p in body['results']) {
          final LatLng pos = LatLng(
            p['geometry']['location']['lat'],
            p['geometry']['location']['lng'],
          );
          _markers.add(
            Marker(
              markerId: MarkerId(p['place_id']),
              position: pos,
              infoWindow: InfoWindow(title: p['name'], snippet: p['vicinity']),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                type == 'hospital'
                    ? BitmapDescriptor.hueRed
                    : type == 'fire_station'
                    ? BitmapDescriptor.hueOrange
                    : type == 'social_services'
                    ? BitmapDescriptor.hueViolet
                    : BitmapDescriptor.hueGreen,
              ),
            ),
          );
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Nakhwa.background,
        appBar: AppBar(
          backgroundColor: Nakhwa.background,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'خرائط الأمان',
            style: TextStyle(color: Colors.white),
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(color: Colors.white24, height: 1),
          ),
        ),
        body: _currentLocation == null
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentLocation!,
                  zoom: 14,
                ),
                markers: _markers,
                myLocationEnabled: true,
                onMapCreated: (c) => _mapController.complete(c),
                zoomControlsEnabled: false,
              ),
      ),
    );
  }
}
