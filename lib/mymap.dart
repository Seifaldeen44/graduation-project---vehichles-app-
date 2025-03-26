import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyMap extends StatefulWidget {
  final String vehicleId;
  const MyMap(this.vehicleId, {super.key});

  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  GoogleMapController? _controller;
  final Map<String, Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _trackVehicles();
  }

  void _trackVehicles() {
    FirebaseFirestore.instance.collection('vehicles').snapshots().listen((snapshot) {
      if (!mounted) return;

      setState(() {
        _markers.clear();
        for (var doc in snapshot.docs) {
          var data = doc.data();
          if (data.containsKey('latitude') && data.containsKey('longitude')) {
            _markers[doc.id] = Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(data['latitude'], data['longitude']),
              infoWindow: InfoWindow(title: data['name']),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              onTap: () => _moveCamera(data['latitude'], data['longitude']),
            );
          }
        }
      });
    });
  }

  void _moveCamera(double lat, double lng) {
    if (_controller != null) {
      _controller!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(lat, lng), zoom: 14.5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vehicle Locations')),
      body: GoogleMap(
        mapType: MapType.normal,
        markers: Set<Marker>.of(_markers.values),
        initialCameraPosition: CameraPosition(target: LatLng(30.0444, 31.2357), zoom: 12), // Cairo Default
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
