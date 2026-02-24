import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class LocationMapsDemo extends StatefulWidget {
  const LocationMapsDemo({super.key});

  @override
  State<LocationMapsDemo> createState() => _LocationMapsDemoState();
}

class _LocationMapsDemoState extends State<LocationMapsDemo> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  BitmapDescriptor? _customIcon;
  bool _isLoading = true;
  bool _isTracking = false;
  String _statusMessage = 'Getting location...';
  StreamSubscription<Position>? _positionStreamSubscription;

  // Sample points of interest
  final List<LatLng> _pointsOfInterest = [
    const LatLng(37.7749, -122.4194), // San Francisco
    const LatLng(40.7128, -74.0060), // New York
    const LatLng(51.5074, -0.1278), // London
    const LatLng(35.6762, 139.6503), // Tokyo
  ];

  @override
  void initState() {
    super.initState();
    _initializeLocationServices();
    _loadCustomMarker();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocationServices() async {
    try {
      // Request permissions
      bool hasPermission = await _requestLocationPermission();
      if (!hasPermission) {
        setState(() {
          _statusMessage = 'Location permission denied';
          _isLoading = false;
        });
        return;
      }

      // Get current location
      await _getCurrentLocation();
      
      // Start location tracking
      _startLocationTracking();
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
        _isLoading = false;
      });
      debugPrint('Location initialization error: $e');
    }
  }

  Future<bool> _requestLocationPermission() async {
    try {
      // Check location service
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Request to enable location service
        serviceEnabled = await Geolocator.openLocationSettings();
        if (!serviceEnabled) {
          return false;
        }
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      return permission == LocationPermission.whileInUse ||
             permission == LocationPermission.always;
    } catch (e) {
      debugPrint('Permission request error: $e');
      return false;
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _currentPosition = position;
        _isLoading = false;
        _statusMessage = 'Location acquired successfully';
      });

      // Add user marker
      _addUserMarker(position.latitude, position.longitude);

      // Move camera to user location
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 15,
            ),
          ),
        );
      }

      debugPrint('User location: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to get location: $e';
        _isLoading = false;
      });
      debugPrint('Get location error: $e');
    }
  }

  void _startLocationTracking() {
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = position;
        _statusMessage = 'Live tracking active';
      });

      // Update user marker
      _addUserMarker(position.latitude, position.longitude);

      debugPrint('Location updated: ${position.latitude}, ${position.longitude}');
    });
  }

  Future<void> _loadCustomMarker() async {
    try {
      // For demo purposes, create a colored marker instead of loading from assets
      _customIcon = BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueBlue,
      );
    } catch (e) {
      debugPrint('Error loading custom marker: $e');
      _customIcon = BitmapDescriptor.defaultMarker;
    }
  }

  void _addUserMarker(double latitude, double longitude) {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == 'user_location');
      _markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(latitude, longitude),
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'Current position',
          ),
          icon: _customIcon ?? BitmapDescriptor.defaultMarker,
          zIndex: 2,
        ),
      );
    });
  }

  void _addPointsOfInterestMarkers() {
    final List<String> poiNames = [
      'San Francisco',
      'New York', 
      'London',
      'Tokyo'
    ];

    for (int i = 0; i < _pointsOfInterest.length; i++) {
      _markers.add(
        Marker(
          markerId: MarkerId('poi_$i'),
          position: _pointsOfInterest[i],
          infoWindow: InfoWindow(
            title: poiNames[i],
            snippet: 'Point of Interest',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
          zIndex: 1,
        ),
      );
    }
    setState(() {});
  }

  void _toggleTracking() {
    setState(() {
      _isTracking = !_isTracking;
      if (_isTracking) {
        _statusMessage = 'Live tracking started';
      } else {
        _statusMessage = 'Live tracking stopped';
      }
    });
  }

  void _centerOnUser() {
    if (_currentPosition != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
            zoom: 15,
          ),
        ),
      );
    }
  }

  void _showAllPoints() {
    if (_mapController != null) {
      _addPointsOfInterestMarkers();
      
      // Calculate bounds to show all points
      double minLat = _pointsOfInterest.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
      double maxLat = _pointsOfInterest.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
      double minLng = _pointsOfInterest.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
      double maxLng = _pointsOfInterest.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          100.0, // padding
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location & Maps Demo'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(37.7749, -122.4194), // San Francisco
              zoom: 10,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              debugPrint('Map created successfully');
            },
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            compassEnabled: true,
            mapToolbarEnabled: false,
            trafficEnabled: false,
            buildingsEnabled: true,
          ),

          // Status overlay
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Status: $_statusMessage',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (_currentPosition != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Accuracy: ${_currentPosition!.accuracy.toStringAsFixed(1)}m',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Loading indicator
          if (_isLoading)
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Getting your location...'),
                    ],
                  ),
                ),
              ),
            ),

          // Control buttons
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: "center",
                  onPressed: _centerOnUser,
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: "tracking",
                  onPressed: _toggleTracking,
                  backgroundColor: _isTracking ? Colors.red : Colors.green,
                  child: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: "poi",
                  onPressed: _showAllPoints,
                  backgroundColor: Colors.orange,
                  child: const Icon(Icons.place),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
