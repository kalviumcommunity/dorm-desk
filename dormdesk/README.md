# dormdesk - Google Maps Integration

A Flutter project demonstrating comprehensive Google Maps integration with real-time location tracking, interactive markers, and advanced map controls.

## Google Maps Integration Overview

### Complete Implementation
1. **Google Maps Setup** - API key configuration for Android and iOS
2. **Location Services** - Real-time GPS tracking and permission handling
3. **Interactive Markers** - Dynamic marker creation with info windows
4. **Map Controls** - Zoom, pan, and gesture controls
5. **User Location** - Current location display and navigation

## Implementation Details

### 1. Dependencies Setup

#### Add Required Packages
```yaml
dependencies:
  google_maps_flutter: ^2.5.3
  location: ^5.0.3
  permission_handler: ^11.3.1
```

#### Install Dependencies
```bash
flutter pub get
```

### 2. Google Maps API Key Configuration

#### Get API Key from Google Cloud Console
1. **Go to Google Cloud Console** → APIs & Services → Credentials
2. **Enable Required APIs**:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Geocoding API (optional)
   - Places API (optional)
3. **Create API Key** and copy it

#### Android Configuration
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<!-- Google Maps API Key -->
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>

<!-- Location Permissions -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

#### iOS Configuration
Add to `ios/Runner/AppDelegate.swift`:
```swift
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

Add to `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app requires location access to display maps and show your current location.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app requires location access to display maps and show your current location.</string>
```

### 3. Basic Map Implementation

#### Minimal Map Widget
```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Google Map")),
      body: const GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(37.7749, -122.4194), // San Francisco
          zoom: 12,
        ),
      ),
    );
  }
}
```

### 4. Location Services Integration

#### Initialize Location Services
```dart
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> _initializeLocation() async {
  try {
    Location location = Location();
    
    // Check if location service is enabled
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    // Check location permissions
    var permission = await Permission.location.status;
    if (permission.isDenied) {
      permission = await Permission.location.request();
      if (permission.isDenied) return;
    }

    // Get current location
    LocationData currentLocation = await location.getLocation();
    
    // Move camera to current location
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              currentLocation.latitude!,
              currentLocation.longitude!,
            ),
            zoom: 15,
          ),
        ),
      );
    }
  } catch (e) {
    print('Error getting location: $e');
  }
}
```

### 5. Interactive Markers

#### Add Markers to Map
```dart
final Set<Marker> _markers = {};

void _addSampleMarkers() {
  final markers = <Marker>{};
  
  markers.add(
    Marker(
      markerId: MarkerId('delhi'),
      position: LatLng(28.6139, 77.2090),
      infoWindow: InfoWindow(
        title: 'New Delhi',
        snippet: 'Capital of India',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ),
  );

  setState(() {
    _markers.addAll(markers);
  });
}

// Display markers in GoogleMap widget
GoogleMap(
  markers: _markers,
  // ... other properties
)
```

#### Dynamic Marker Creation
```dart
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
}
```

### 6. Advanced Map Features

#### Enable User Location
```dart
GoogleMap(
  initialCameraPosition: const CameraPosition(
    target: LatLng(0, 0),
    zoom: 2,
  ),
  myLocationEnabled: true,
  myLocationButtonEnabled: true,
  // ... other properties
)
```

#### Map Controls and Gestures
```dart
GoogleMap(
  // Basic controls
  zoomControlsEnabled: true,
  mapToolbarEnabled: true,
  compassEnabled: true,
  
  // Gesture controls
  scrollGesturesEnabled: true,
  zoomGesturesEnabled: true,
  tiltGesturesEnabled: true,
  rotateGesturesEnabled: true,
  
  // Map type
  mapType: MapType.normal,
  
  // Event handlers
  onTap: (LatLng position) => _addNewMarker(position),
  onLongPress: (LatLng position) => _addNewMarker(position),
  onMapCreated: (GoogleMapController controller) {
    _mapController = controller;
  },
)
```

#### Map Types
```dart
enum MapType {
  normal,    // Standard road map
  satellite,  // Satellite imagery
  hybrid,     // Satellite with road overlays
  terrain,    // Topographic data
}
```

## Features Implemented

### 1. **Location Services**
- **Permission Handling**: Request and check location permissions
- **Service Status**: Check if location services are enabled
- **Real-time Updates**: Get current GPS coordinates
- **Error Handling**: Graceful error recovery and user feedback

### 2. **Interactive Map**
- **Pan & Zoom**: Smooth map navigation with gestures
- **Map Controls**: Built-in zoom buttons and compass
- **Map Types**: Switch between normal, satellite, hybrid views
- **Camera Control**: Programmatic camera movement and animation

### 3. **Dynamic Markers**
- **Sample Markers**: Pre-populated locations for demonstration
- **Custom Markers**: Add markers by tapping on map
- **Info Windows**: Display location details on marker tap
- **Marker Management**: Add, clear, and organize markers

### 4. **User Experience**
- **Loading States**: Visual feedback during initialization
- **Error Handling**: User-friendly error messages
- **Navigation**: Go to current location button
- **Feedback**: SnackBar notifications for user actions

## Code Examples

### Basic Map with Controls
```dart
GoogleMap(
  onMapCreated: (GoogleMapController controller) {
    _mapController = controller;
  },
  initialCameraPosition: CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 12,
  ),
  markers: _markers,
  myLocationEnabled: true,
  myLocationButtonEnabled: true,
  zoomControlsEnabled: true,
  mapToolbarEnabled: true,
  compassEnabled: true,
  onTap: _addNewMarker,
)
```

### Location Permission Request
```dart
Future<bool> _requestLocationPermission() async {
  var permission = await Permission.location.status;
  
  if (permission.isDenied) {
    permission = await Permission.location.request();
    if (permission.isGranted) {
      return true;
    }
  } else if (permission.isGranted) {
    return true;
  }
  
  return false;
}
```

### Camera Animation
```dart
void _animateToLocation(LatLng target, {double zoom = 15}) {
  _mapController?.animateCamera(
    CameraUpdate.newCameraPosition(
      CameraPosition(
        target: target,
        zoom: zoom,
      ),
    ),
  );
}
```

## Testing & Verification

### Manual Testing Checklist
- [ ] Map loads without errors
- [ ] Location permission dialog appears
- [ ] Current location button works
- [ ] Markers display correctly
- [ ] Tap to add marker works
- [ ] Info windows show on marker tap
- [ ] Map controls (zoom, pan) work
- [ ] Error handling works gracefully

### API Key Verification
1. **Replace `YOUR_API_KEY_HERE`** with actual Google Maps API key
2. **Enable required APIs** in Google Cloud Console
3. **Test on real device** (emulator may have location limitations)
4. **Check console logs** for API key errors

## Common Issues & Solutions

### API Key Issues
- **Problem**: Map doesn't load, shows gray screen
- **Solution**: Verify API key is correct and enabled APIs

### Permission Issues
- **Problem**: Location permission denied
- **Solution**: Check app permissions in device settings

### Emulator Issues
- **Problem**: Location not working on emulator
- **Solution**: Use mock location or test on real device

### Build Issues
- **Problem**: Build fails after adding maps
- **Solution**: Run `flutter clean` and `flutter pub get`

## Getting Started

1. **Get Google Maps API Key** from Google Cloud Console
2. **Replace `YOUR_API_KEY_HERE`** in AndroidManifest.xml and AppDelegate.swift
3. **Enable required APIs** in Google Cloud Console
4. **Run app**: `flutter run`
5. **Grant location permissions** when prompted
6. **Test map features**: Add markers, navigate, zoom

## Key Learnings

### Google Maps Integration
- **API Key Management**: Secure handling of API keys
- **Platform Configuration**: Different setup for Android and iOS
- **Permission Handling**: User-friendly permission requests
- **Error Recovery**: Graceful handling of location failures

### Location Services
- **Real-time Tracking**: Continuous location updates
- **Permission Flow**: Proper permission request sequence
- **Battery Optimization**: Efficient location usage
- **User Privacy**: Clear permission explanations

### Map Interactions
- **Gesture Handling**: Responsive map interactions
- **Marker Management**: Dynamic marker creation and removal
- **Camera Control**: Smooth animations and positioning
- **User Feedback**: Clear visual and text feedback
