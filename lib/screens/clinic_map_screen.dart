import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'dart:math';
import 'dart:async';
import '../models/vet_clinic.dart';

class ClinicMapScreen extends StatefulWidget {
  final VetClinic clinic;
  final double userLat;
  final double userLng;

  const ClinicMapScreen({
    Key? key,
    required this.clinic,
    required this.userLat,
    required this.userLng,
  }) : super(key: key);

  @override
  State<ClinicMapScreen> createState() => _ClinicMapScreenState();
}

class _ClinicMapScreenState extends State<ClinicMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  List<PointLatLng> routePoints = [];
  PolylinePoints polylinePoints = PolylinePoints();
  bool _isLoading = false;
  bool _isNavigating = false;
  late Location _location;
  StreamSubscription<LocationData>? _locationSubscription;
  int _currentRouteIndex = 0;
  double _distanceToNextPoint = 0;
  String _navigationInstruction = "Preparing route...";
  BitmapDescriptor _userMarkerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  double _remainingDistance = 0;
  String _estimatedArrival = "";

  @override
  void initState() {
    super.initState();
    _location = Location();
    _checkLocationPermission();
    _getPolylinePoints();
    _setupCustomMarker();
  }

  void _setupCustomMarker() async {
    // You could load custom marker icon here if needed
    setState(() {
      _userMarkerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    });
  }

  Future<void> _checkLocationPermission() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Radius of the Earth in km
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  // Get direction from Google Directions API
  Future<void> _getPolylinePoints() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await polylinePoints.getRouteBetweenCoordinates(
        'YOUR_API', // Replace with your actual Google API key
        PointLatLng(widget.userLat, widget.userLng),
        PointLatLng(widget.clinic.latitude, widget.clinic.longitude),
        travelMode: TravelMode.driving,
      );

      if (result.points.isNotEmpty) {
        routePoints = result.points;
        polylineCoordinates = routePoints
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        // Calculate estimated arrival time (rough estimate)
        final totalDistance = _calculateRouteDistance(polylineCoordinates);
        final averageSpeed = 40; // km/h, just an estimate
        final travelTimeHours = totalDistance / averageSpeed;
        final arrivalTime = DateTime.now().add(Duration(minutes: (travelTimeHours * 60).round()));

        setState(() {
          _remainingDistance = totalDistance;
          _estimatedArrival = "ETA: ${_formatTime(arrivalTime)}";
        });
      } else {
        // Fallback to direct line if API returns empty
        polylineCoordinates = [
          LatLng(widget.userLat, widget.userLng),
          LatLng(widget.clinic.latitude, widget.clinic.longitude),
        ];

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not get directions. Showing direct path instead.'),
            duration: Duration(seconds: 3),
          ),
        );
      }

      _addPolyLine();
    } catch (e) {
      // If the API call fails, fall back to a straight line
      polylineCoordinates = [
        LatLng(widget.userLat, widget.userLng),
        LatLng(widget.clinic.latitude, widget.clinic.longitude),
      ];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting directions: ${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );

      _addPolyLine();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  double _calculateRouteDistance(List<LatLng> route) {
    double totalDistance = 0;
    for (int i = 0; i < route.length - 1; i++) {
      totalDistance += calculateDistance(
        route[i].latitude, route[i].longitude,
        route[i + 1].latitude, route[i + 1].longitude,
      );
    }
    return totalDistance;
  }

  _addPolyLine() {
    PolylineId id = const PolylineId("route");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: polylineCoordinates,
      width: 5,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }

  Future<void> _startNavigation() async {
    if (_isNavigating) {
      _stopNavigation();
      return;
    }

    setState(() {
      _isNavigating = true;
      _currentRouteIndex = 0;
      _navigationInstruction = "Starting navigation...";
    });

    // Set up location tracking with higher accuracy
    _location.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 1000,
      distanceFilter: 5,
    );

    // Start location updates
    _locationSubscription = _location.onLocationChanged.listen((LocationData currentLocation) {
      _updateNavigation(currentLocation);
      _updateCameraPosition(currentLocation);
    });

    // Initial camera animation to follow user
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(widget.userLat, widget.userLng),
          zoom: 17.0,
          tilt: 45.0,
          bearing: 0,
        ),
      ),
    );
  }

  void _stopNavigation() {
    _locationSubscription?.cancel();
    setState(() {
      _isNavigating = false;
      _navigationInstruction = "Navigation stopped";
    });
  }

  void _updateNavigation(LocationData currentLocation) {
    if (routePoints.isEmpty || _currentRouteIndex >= routePoints.length) {
      return;
    }

    // Calculate distance to next route point
    final currentPosition = LatLng(currentLocation.latitude!, currentLocation.longitude!);
    final nextRoutePoint = routePoints[_currentRouteIndex];
    final nextRouteLatLng = LatLng(nextRoutePoint.latitude, nextRoutePoint.longitude);

    _distanceToNextPoint = calculateDistance(
        currentPosition.latitude, currentPosition.longitude,
        nextRouteLatLng.latitude, nextRouteLatLng.longitude
    );

    // Calculate remaining distance to destination
    double remainingDistance = 0;
    for (int i = _currentRouteIndex; i < routePoints.length - 1; i++) {
      remainingDistance += calculateDistance(
          routePoints[i].latitude, routePoints[i].longitude,
          routePoints[i + 1].latitude, routePoints[i + 1].longitude
      );
    }

    // Generate navigation instruction based on heading
    String instruction = "Continue straight";
    if (_currentRouteIndex < routePoints.length - 1) {
      // Calculate bearing for current segment
      final nextPoint = routePoints[_currentRouteIndex + 1];
      final bearing = _getBearing(
          nextRoutePoint.latitude, nextRoutePoint.longitude,
          nextPoint.latitude, nextPoint.longitude
      );

      // Determine turn instruction
      if (bearing > 30 && bearing <= 150) {
        instruction = "Turn right ahead";
      } else if (bearing > 150 && bearing <= 210) {
        instruction = "Continue straight";
      } else if (bearing > 210 && bearing <= 330) {
        instruction = "Turn left ahead";
      } else {
        instruction = "Make a U-turn";
      }
    }

    // If we're close enough to this point, move to the next one
    if (_distanceToNextPoint < 0.02) { // 20 meters
      if (_currentRouteIndex < routePoints.length - 1) {
        _currentRouteIndex++;
      } else {
        instruction = "You have arrived at your destination";
        _stopNavigation();
      }
    }

    setState(() {
      _navigationInstruction = instruction;
      _remainingDistance = remainingDistance;

      // Update ETA
      final averageSpeed = 40; // km/h
      final travelTimeHours = remainingDistance / averageSpeed;
      final arrivalTime = DateTime.now().add(Duration(minutes: (travelTimeHours * 60).round()));
      _estimatedArrival = "ETA: ${_formatTime(arrivalTime)}";
    });
  }

  double _getBearing(double startLat, double startLng, double endLat, double endLng) {
    double latitude1 = _deg2rad(startLat);
    double latitude2 = _deg2rad(endLat);
    double longDiff = _deg2rad(endLng - startLng);

    double y = sin(longDiff) * cos(latitude2);
    double x = cos(latitude1) * sin(latitude2) - sin(latitude1) * cos(latitude2) * cos(longDiff);

    double bearing = atan2(y, x);
    bearing = (bearing * 180 / pi + 360) % 360; // Convert to degrees
    return bearing;
  }

  Future<void> _updateCameraPosition(LocationData locationData) async {
    if (!_isNavigating) return;

    final GoogleMapController controller = await _controller.future;

    // Calculate bearing to look ahead
    double bearing = 0;
    if (_currentRouteIndex < routePoints.length - 1) {
      final currentPos = LatLng(locationData.latitude!, locationData.longitude!);
      final nextPos = LatLng(
          routePoints[_currentRouteIndex].latitude,
          routePoints[_currentRouteIndex].longitude
      );

      bearing = _getBearing(
          currentPos.latitude, currentPos.longitude,
          nextPos.latitude, nextPos.longitude
      );
    }

    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(locationData.latitude!, locationData.longitude!),
          zoom: 17.0,
          tilt: 45.0,
          bearing: bearing,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final distance = calculateDistance(
        widget.userLat,
        widget.userLng,
        widget.clinic.latitude,
        widget.clinic.longitude
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNavigating
            ? 'Navigating to ${widget.clinic.name}'
            : 'Map - ${widget.clinic.name}'
        ),
        backgroundColor: Color(0xFFFFFBF2),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                (widget.userLat + widget.clinic.latitude) / 2,
                (widget.userLng + widget.clinic.longitude) / 2,
              ),
              zoom: 12,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('user'),
                position: LatLng(widget.userLat, widget.userLng),
                infoWindow: const InfoWindow(title: 'Your Location'),
                icon: _userMarkerIcon,
              ),
              Marker(
                markerId: const MarkerId('clinic'),
                position: LatLng(widget.clinic.latitude, widget.clinic.longitude),
                infoWindow: InfoWindow(
                  title: widget.clinic.name,
                  snippet: 'Distance: ${distance.toStringAsFixed(2)} km',
                ),
              ),
            },
            polylines: Set<Polyline>.of(polylines.values),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            ),
          if (_isNavigating)
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _navigationInstruction,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_remainingDistance.toStringAsFixed(1)} km remaining',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            _estimatedArrival,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startNavigation,
        label: Text(_isNavigating ? 'Stop Navigation' : 'Start Navigation',
            style: const TextStyle(color: Colors.white)),
        icon: Icon(_isNavigating ? Icons.stop : Icons.navigation),
        backgroundColor: _isNavigating ? Colors.red : Colors.orange[700],
      ),
    );
  }
}
