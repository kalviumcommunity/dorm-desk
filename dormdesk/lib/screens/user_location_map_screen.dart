import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class UserLocationMapScreen extends StatefulWidget {
  const UserLocationMapScreen({super.key});

  @override
  State<UserLocationMapScreen> createState() =>
      _UserLocationMapScreenState();
}

class _UserLocationMapScreenState
    extends State<UserLocationMapScreen> {

  GoogleMapController? mapController;

  LatLng currentPosition = const LatLng(13.0827, 80.2707);

  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    LatLng userLatLng =
        LatLng(position.latitude, position.longitude);

    setState(() {

      currentPosition = userLatLng;

      markers = {
        Marker(
          markerId: const MarkerId("user_location"),
          position: userLatLng,
          infoWindow: const InfoWindow(
            title: "You are here",
          ),
        ),
      };
    });

    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(userLatLng, 16),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("DormDesk Location"),
      ),
      body: GoogleMap(

        onMapCreated: _onMapCreated,

        initialCameraPosition: CameraPosition(
          target: currentPosition,
          zoom: 14,
        ),

        markers: markers,

        myLocationEnabled: true,
        myLocationButtonEnabled: true,

        zoomControlsEnabled: true,

      ),
    );
  }
}