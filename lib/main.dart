import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';

void main() => runApp(MaterialApp(
      home: MyMap(),
    ));

class MyMap extends StatefulWidget {
  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  //Position currentPos;
  String error;
  LocationData _currentLocation;
  Location _locationService = new Location();
  bool _permission = false;

  @override
  void initState() {
    super.initState();
    initLocation();
  }

  void initLocation() async {
    await _locationService.changeSettings(
        accuracy: LocationAccuracy.HIGH, interval: 1000);
    LocationData location;

    try {
      bool serviceStatus = await _locationService.serviceEnabled();
      print("Service status: $serviceStatus");

      if (serviceStatus) {
        _permission = await _locationService.requestPermission();
        print("Permission: $_permission");

        if (_permission) {
          location = await _locationService.getLocation();
        }

        if (mounted) {
          setState(() {
            _currentLocation = location;
          });
        }
      } else {
        bool serviceStatusResult = await _locationService.requestService();
        print("Service status activated after request: $serviceStatusResult");
        if (serviceStatusResult) {
          initLocation();
        }
      }

      setState(() {
        _currentLocation = location;
      });
    } on PlatformException catch (e) {
      print(e);

      if (e.code == 'PERMISSION_DENIED') {
        error = e.message;
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        error = e.message;
      }
      location = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // print("*******************  Longiude is: ${_currentLocation.latitude}");

    return Container(
        child: FlutterMap(
            options: MapOptions(
              minZoom: 5.0,
              center:
                  LatLng(_currentLocation.latitude, _currentLocation.longitude),
            ),
            layers: [
          TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c']),
        ]));
  }
}
