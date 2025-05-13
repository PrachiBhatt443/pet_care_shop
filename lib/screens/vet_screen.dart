import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../widgets/location_header.dart';
import '../widgets/map_sample.dart';
import '../services/osm_places_services.dart';
import '../models/vet_clinic.dart';
import '../widgets/nearby_clinics_list.dart';
import '../widgets/all_clinics_list.dart';
import '../services/places_services.dart';

class VetScreen extends StatefulWidget {
  const VetScreen({Key? key}) : super(key: key);

  @override
  State<VetScreen> createState() => _VetScreenState();
}

class _VetScreenState extends State<VetScreen> {
  String _location = 'Fetching location...';
  List<VetClinic> _nearbyClinics = [];
  List<VetClinic> _allClinics = [];
  Position? _userPosition; // Added to store user position globally

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

    if (!serviceEnabled) {
      setState(() => _location = 'Location services are disabled.');
      return;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _location = 'Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _location = 'Location permissions are permanently denied');
      return;
    }

    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    try {
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      final placemark = placemarks.first;

      final clinicMap = await GooglePlacesService()
          .getNearbyVetClinics(position.latitude, position.longitude);

      // Extract both lists
      final withImages = clinicMap['withImages']!;
      final withoutImages = clinicMap['withoutImages']!;

      // Convert to VetClinic model
      final nearbyClinics = withImages.map((c) => VetClinic.fromMap(c)).toList();
      final allClinics = [...withImages, ...withoutImages]
          .map((c) => VetClinic.fromMap(c))
          .toList();

      setState(() {
        _location = '${placemark.locality}, ${placemark.administrativeArea}';
        _nearbyClinics = nearbyClinics;
        _allClinics = allClinics;
        _userPosition = position; // Set globally for use in build()
      });
    } catch (e) {
      setState(() => _location = 'Location not found');
      print('Error fetching location or clinics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                LocationHeader(location: _location),
                const Text(
                  'Nearby Vet Clinics:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _nearbyClinics.isEmpty
                    ? const Text("No clinics found nearby.")
                    : NearbyClinicsList(clinics: _nearbyClinics),
                const SizedBox(height: 20),
                const Text(
                  'All Clinics:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                (_allClinics.isEmpty || _userPosition == null)
                    ? const SizedBox.shrink()
                    : AllClinicsList(
                  clinics: _allClinics,
                  userLat: _userPosition!.latitude,
                  userLng: _userPosition!.longitude,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
