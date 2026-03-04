import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPreviewScreen extends StatefulWidget {
  const LocationPreviewScreen({super.key});

  @override
  State<LocationPreviewScreen> createState() =>
      _LocationPreviewScreenState();
}

class _LocationPreviewScreenState
    extends State<LocationPreviewScreen> {

  late GoogleMapController mapController;

  final LatLng defaultLocation =
      const LatLng(13.0827, 80.2707); // Chennai

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  final Set<Marker> markers = {
    const Marker(
      markerId: MarkerId("chennai_marker"),
      position: LatLng(13.0827, 80.2707),
      infoWindow: InfoWindow(
        title: "DormDesk Location",
        snippet: "Chennai Hostel Area",
      ),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Location Preview"),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,

        initialCameraPosition: const CameraPosition(
          target: LatLng(13.0827, 80.2707),
          zoom: 14,
        ),

        markers: markers,

        myLocationEnabled: true,
        myLocationButtonEnabled: true,

        zoomControlsEnabled: true,
        mapType: MapType.normal,
      ),
    );
  }
}