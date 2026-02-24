import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Location? _location;
  LocationData? _currentLocation;
  bool _isLoading = true;
  String? _error;

  // Initial camera position (San Francisco)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 12,
  );

  // Markers set
  final Set<Marker> _markers = {};

  // Sample locations for markers
  final List<LatLng> _sampleLocations = [
    const LatLng(37.7749, -122.4194), // San Francisco
    const LatLng(37.7849, -122.4094), // Near SF
    const LatLng(37.7649, -122.4294), // Another SF location
    const LatLng(28.6139, 77.2090),  // New Delhi
    const LatLng(40.7128, -74.0060), // New York
  ];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _addSampleMarkers();
  }

  Future<void> _initializeLocation() async {
    try {
      _location = Location();
      
      // Check if location service is enabled
      bool serviceEnabled = await _location!.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location!.requestService();
        if (!serviceEnabled) {
          setState(() {
            _error = 'Location services are disabled. Please enable them.';
            _isLoading = false;
          });
          return;
        }
      }

      // Check location permissions
      var permission = await Permission.location.status;
      if (permission.isDenied) {
        permission = await Permission.location.request();
        if (permission.isDenied) {
          setState(() {
            _error = 'Location permission denied. Please grant permission to use location features.';
            _isLoading = false;
          });
          return;
        }
      }

      // Get current location
      _currentLocation = await _location!.getLocation();
      
      setState(() {
        _isLoading = false;
      });

      // Move camera to current location if available
      if (_currentLocation != null && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                _currentLocation!.latitude!,
                _currentLocation!.longitude!,
              ),
              zoom: 15,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Error getting location: $e';
        _isLoading = false;
      });
    }
  }

  void _addSampleMarkers() {
    final markers = <Marker>{};
    
    // Add sample markers
    for (int i = 0; i < _sampleLocations.length; i++) {
      final location = _sampleLocations[i];
      markers.add(
        Marker(
          markerId: MarkerId('location_$i'),
          position: location,
          infoWindow: InfoWindow(
            title: 'Location ${i + 1}',
            snippet: 'Lat: ${location.latitude}, Lng: ${location.longitude}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            i % 2 == 0 ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueRed,
          ),
        ),
      );
    }

    // Add current location marker if available
    if (_currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
            _currentLocation!.latitude!,
            _currentLocation!.longitude!,
          ),
          infoWindow: const InfoWindow(
            title: 'Current Location',
            snippet: 'You are here',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }

    setState(() {
      _markers.addAll(markers);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    
    // Move to current location if available after map is created
    if (_currentLocation != null) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              _currentLocation!.latitude!,
              _currentLocation!.longitude!,
            ),
            zoom: 15,
          ),
        ),
      );
    }
  }

  Future<void> _goToCurrentLocation() async {
    if (_currentLocation != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              _currentLocation!.latitude!,
              _currentLocation!.longitude!,
            ),
            zoom: 15,
          ),
        ),
      );
    } else {
      // Try to get current location again
      await _initializeLocation();
    }
  }

  void _addNewMarker(LatLng position) {
    final markerId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(markerId),
          position: position,
          infoWindow: InfoWindow(
            title: 'Custom Marker',
            snippet: 'Added at ${DateTime.now().toString().substring(0, 19)}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Marker added successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearMarkers() {
    setState(() {
      _markers.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All markers cleared!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _goToCurrentLocation,
            tooltip: 'Go to Current Location',
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearMarkers,
            tooltip: 'Clear All Markers',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add marker at center of map
          if (_mapController != null) {
            _mapController!.getVisibleRegion().then((bounds) {
              final center = LatLng(
                (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
                (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
              );
              _addNewMarker(center);
            });
          }
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add_location, color: Colors.white),
        tooltip: 'Add Marker at Center',
      ),
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
            Text('Loading map...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _error = null;
                  _isLoading = true;
                });
                _initializeLocation();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: _initialPosition,
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: true,
      mapToolbarEnabled: true,
      compassEnabled: true,
      mapType: MapType.normal,
      onTap: _addNewMarker,
      onLongPress: (LatLng position) {
        _addNewMarker(position);
      },
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
