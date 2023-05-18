import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  static final LatLng _position = LatLng(15.98136625534374, 120.57155419700595);
  late GoogleMapController _mapController;

  List<Marker> _markers = [
    Marker(
      markerId: MarkerId('initial'),
      position: _position,
    ),
  ];

  Future<bool> checkServicePermission() async {
    LocationPermission _permission;
    bool isEnabled = await Geolocator.isLocationServiceEnabled();
    print(isEnabled);

    if (!isEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Location services is disabled. Please enable it in the settings.')),
      );
      return false;
    }

    //check permission
    _permission = await Geolocator.checkPermission();
    if (_permission == LocationPermission.denied) {
      //ask for pemission
      _permission = await Geolocator.requestPermission();
      if (_permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Location permission is denied. Please accept the location permission of the app to continue.')),
        );
        return false;
      }
    }
    if (_permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Location permission is permantly denied denied. Please change in the settings.')),
      );
      return false;
    }

    return true;
  }

  Future<void> getLocation() async {
    if (!await checkServicePermission()) return;

    await Geolocator.getPositionStream(
      locationSettings:
          LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 0),
    ).listen((position) {
      print(position);
      placeMarker(LatLng(position.latitude, position.longitude));
    });
  }

  void placeMarker(LatLng pos) {
    _markers.clear();
    _markers.add(
      Marker(
        markerId: MarkerId('${pos.latitude + pos.longitude}'),
        position: pos,
        infoWindow: InfoWindow(title: 'My Location'),
      ),
    );
    //zoom
    CameraPosition _cameraPosition = CameraPosition(target: pos, zoom: 18);
    _mapController
        .animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GoogleMap(
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          zoomControlsEnabled: true,
          initialCameraPosition:
              CameraPosition(target: _position, zoom: 14, bearing: 0, tilt: 0),
          onTap: (pos) {
            print(pos);
            placeMarker(pos);
          },
          onMapCreated: (controller) {
            _mapController = controller;
          },
          markers: _markers.toSet(),
        ),
      ),
    );
  }
}
