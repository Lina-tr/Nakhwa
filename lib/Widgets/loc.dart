import 'package:geolocator/geolocator.dart';

class LocationHelper {
  static Future<void> setCurrentLocationToController(
    controller,
    context,
  ) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('خدمات الموقع غير مفعلة.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('تم رفض أذونات الموقع.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('تم رفض أذونات الموقع بشكل دائم.');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      controller.text =
          'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
    } catch (e) {
      rethrow;
    }
  }
}
