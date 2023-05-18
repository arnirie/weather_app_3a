import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class CurrentLocationScreen extends StatefulWidget {
  const CurrentLocationScreen({super.key});

  @override
  State<CurrentLocationScreen> createState() => _CurrentLocationScreenState();
}

class _CurrentLocationScreenState extends State<CurrentLocationScreen> {
  Position? _position;

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

  Future<void> getCurrentLocation() async {
    //get curent location
    if (!await checkServicePermission()) {
      return;
    }
    _position = await Geolocator.getCurrentPosition();
    setState(() {});
    print(_position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Current Location'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Lat:${_position?.latitude ?? ''}'),
              Text('Long:${_position?.longitude ?? ''}'),
              ElevatedButton(
                  onPressed: getCurrentLocation,
                  child: const Text('Get My Current Location')),
            ],
          ),
        ),
      ),
    );
  }
}
