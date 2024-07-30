import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:firebase_database/firebase_database.dart';

class MapScreen extends StatefulWidget {
  final String companyId;
  final String truckId;
  final String truckName;

  const MapScreen({Key? key, required this.companyId, required this.truckId, required this.truckName}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Location _locationController = Location();
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  LatLng? _currentPosition;
  bool _isLive = false;
  DatabaseReference? _truckLocationRef;
  StreamSubscription<LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndLocationServices();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadMapStyle(GoogleMapController controller) async {
    final String mapStyle = '''
    [
      {
        "featureType": "poi.business",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      }
    ]
    '''; // Add your custom style JSON here if you have additional styles

    await controller.setMapStyle(mapStyle);
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.truckName),
        backgroundColor: const Color(0xFF1C1C1E), // Match the color from the Homepage
        iconTheme: IconThemeData(color: Colors.white), // Set back arrow color to white
      ),
      body: _currentPosition == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _mapController.complete(controller);
                    _loadMapStyle(controller); // Apply the map style when the map is created
                  },
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition!,
                    zoom: 15,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 200,
                      child: FloatingActionButton.extended(
                        onPressed: () {
                          setState(() {
                            _isLive = !_isLive;
                            if (_isLive) {
                              _startLiveLocationUpdates();
                            } else {
                              _stopLiveLocationUpdates();
                            }
                          });
                        },
                        label: Text(
                          _isLive ? 'Stop' : 'Go Live',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18
                          ),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _checkPermissionsAndLocationServices() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    LocationData locationData = await _locationController.getLocation();
    setState(() {
      _currentPosition = LatLng(locationData.latitude!, locationData.longitude!);
    });

    _locationSubscription = _locationController.onLocationChanged.listen((LocationData locationData) {
      setState(() {
        _currentPosition = LatLng(locationData.latitude!, locationData.longitude!);
      });

      if (_isLive) {
        _updateLocation(locationData);
      }
    });
  }

  void _startLiveLocationUpdates() {
    _truckLocationRef = FirebaseDatabase.instance.ref('truck_locations/${widget.companyId}/${widget.truckId}');
    print('Started live location updates: truck_locations/${widget.companyId}/${widget.truckId}');
  }

  void _stopLiveLocationUpdates() {
    if (_truckLocationRef != null) {
      _truckLocationRef!.remove();
      print('Stopped live location updates: truck_locations/${widget.companyId}/${widget.truckId}');
    }
  }

  void _updateLocation(LocationData locationData) {
    if (_truckLocationRef != null) {
      _truckLocationRef!.set({
        'latitude': locationData.latitude,
        'longitude': locationData.longitude,
        'timestamp': ServerValue.timestamp,
      }).then((_) {
        print('Location updated successfully');
      }).catchError((error) {
        print('Failed to update location: $error');
      });
    }
  }
}
