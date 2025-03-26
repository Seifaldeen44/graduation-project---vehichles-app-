// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart' as loc;
// import 'package:permission_handler/permission_handler.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MaterialApp(home: RoleSelectionScreen()));
// }
//
// class RoleSelectionScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Select Your Role')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(context, MaterialPageRoute(builder: (context) => UserScreen()));
//               },
//               child: Text('I am a User'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(context, MaterialPageRoute(builder: (context) => VehicleScreen()));
//               },
//               child: Text('I am a Vehicle'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class UserScreen extends StatefulWidget {
//   @override
//   _UserScreenState createState() => _UserScreenState();
// }
//
// class _UserScreenState extends State<UserScreen> {
//   GoogleMapController? _controller;
//   Map<String, Marker> _markers = {};
//   BitmapDescriptor? _userIcon;
//   BitmapDescriptor? _vehicleIcon;
//   loc.Location location = loc.Location();
//
//   @override
//   void initState() {
//     super.initState();
//     _loadIcons();
//     _trackVehicles();
//     _getUserLocation();
//   }
//
//   Future<void> _loadIcons() async {
//     _userIcon = await BitmapDescriptor.fromAssetImage(
//         ImageConfiguration(size: Size(48, 48)), 'assets/user_icon.png');
//
//     _vehicleIcon = await BitmapDescriptor.fromAssetImage(
//         ImageConfiguration(size: Size(300, 300)), // Increase vehicle icon size
//         'assets/car_icon.png');
//
//     setState(() {}); // Refresh UI after loading icons
//   }
//
//
//   void _trackVehicles() {
//     FirebaseFirestore.instance.collection('vehicles')
//         .where('active', isEqualTo: true) // Only active vehicles
//         .snapshots().listen((snapshot) {
//       if (!mounted) return;
//
//       setState(() {
//         for (var doc in snapshot.docs) {
//           var data = doc.data();
//           if (data.containsKey('latitude') && data.containsKey('longitude')) {
//             LatLng position = LatLng(data['latitude'], data['longitude']);
//             _markers[doc.id] = Marker(
//               markerId: MarkerId(doc.id),
//               position: position,
//               infoWindow: InfoWindow(title: data['name']),
//               icon: _vehicleIcon ?? BitmapDescriptor.defaultMarker, // VEHICLE ICON FIXED
//               onTap: () {
//                 _moveCamera(position.latitude, position.longitude);
//               },
//             );
//           }
//         }
//       });
//     });
//   }
//
//   void _getUserLocation() async {
//     var userLocation = await location.getLocation();
//     LatLng position = LatLng(userLocation.latitude!, userLocation.longitude!);
//
//     setState(() {
//       _markers['user'] = Marker(
//         markerId: MarkerId('user'),
//         position: position,
//         infoWindow: InfoWindow(title: 'You'),
//         icon: _userIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue), // USER ICON FIXED
//       );
//       _moveCamera(userLocation.latitude!, userLocation.longitude!);
//     });
//   }
//
//   void _moveCamera(double lat, double lng) {
//     _controller?.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(target: LatLng(lat, lng), zoom: 14.5),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Vehicle Tracker')),
//       body: GoogleMap(
//         mapType: MapType.normal,
//         markers: Set<Marker>.of(_markers.values),
//         initialCameraPosition: CameraPosition(target: LatLng(30.0444, 31.2357), zoom: 12),
//         onMapCreated: (GoogleMapController controller) {
//           _controller = controller;
//         },
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }
// }
//
// class VehicleScreen extends StatefulWidget {
//   @override
//   _VehicleScreenState createState() => _VehicleScreenState();
// }
//
// class _VehicleScreenState extends State<VehicleScreen> {
//   final loc.Location location = loc.Location();
//   StreamSubscription<loc.LocationData>? _locationSubscription;
//   late String vehicleId;
//
//   @override
//   void initState() {
//     super.initState();
//     _requestPermission();
//     _setVehicleId();
//     _startTracking();
//   }
//
//   Future<void> _requestPermission() async {
//     var status = await Permission.location.request();
//     if (!status.isGranted) {
//       openAppSettings();
//     }
//   }
//
//   Future<void> _setVehicleId() async {
//     vehicleId = FirebaseFirestore.instance.collection('vehicles').doc().id;
//     await FirebaseFirestore.instance.collection('vehicles').doc(vehicleId).set({
//       'active': true,
//       'name': 'Vehicle $vehicleId',
//     }, SetOptions(merge: true));
//   }
//
//   void _startTracking() {
//     _locationSubscription = location.onLocationChanged.listen((loc.LocationData currentLocation) async {
//       if (vehicleId.isNotEmpty) {
//         await FirebaseFirestore.instance.collection('vehicles').doc(vehicleId).set({
//           'latitude': currentLocation.latitude,
//           'longitude': currentLocation.longitude,
//           'active': true, // Mark vehicle as active
//         }, SetOptions(merge: true));
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _locationSubscription?.cancel();
//     FirebaseFirestore.instance.collection('vehicles').doc(vehicleId).update({'active': false});
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Vehicle Mode - Tracking Active')),
//       body: Center(
//         child: Text('Your location is being shared...'),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: VehicleScreen()));
}

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({super.key});

  @override
  _VehicleScreenState createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;
  GoogleMapController? _controller;
  LatLng? _currentPosition;
  BitmapDescriptor? _vehicleIcon;
  String? vehicleName;
  String? selectedLine;
  bool isTracking = true;

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _loadVehicleIcon();
    _getLineSelection().then((line) {
      selectedLine = line;
      _getVehicleName().then((name) {
        vehicleName = name;
        _startTracking();
      });
    });
  }

  Future<void> _requestPermission() async {
    var status = await Permission.location.request();
    if (!status.isGranted) {
      openAppSettings();
    }
  }

  Future<void> _loadVehicleIcon() async {
    _vehicleIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(48, 48)),
      'assets/car_icon.png',
    );
  }

  Future<String?> _getLineSelection() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? line = prefs.getString('selectedLine');
    if (line == null) {
      String? result = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Choose Your Line'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(title: Text('Line 1'), onTap: () => Navigator.of(context).pop('line1')),
                ListTile(title: Text('Line 2'), onTap: () => Navigator.of(context).pop('line2')),
              ],
            ),
          );
        },
      );
      if (result != null) {
        await prefs.setString('selectedLine', result);
        return result;
      }
    }
    return line;
  }

  Future<String> _getVehicleName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('vehicleName');
    if (name == null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('vehicles').doc(selectedLine).collection('vehicles').get();
      int count = snapshot.docs.length + 1;
      name = 'vehicle$count';
      await prefs.setString('vehicleName', name);
    }
    return name;
  }

  void _startTracking() {
    _locationSubscription = location.onLocationChanged.listen((loc.LocationData currentLocation) async {
      if (currentLocation.latitude != null && currentLocation.longitude != null && vehicleName != null) {
        LatLng position = LatLng(currentLocation.latitude!, currentLocation.longitude!);
        setState(() {
          _currentPosition = position;
        });
        await FirebaseFirestore.instance.collection('vehicles').doc(selectedLine).collection('vehicles').doc(vehicleName).set({
          'latitude': position.latitude,
          'longitude': position.longitude,
          'name': vehicleName,
          'active': isTracking,
        }, SetOptions(merge: true));
        if (_controller != null) {
          _controller!.animateCamera(CameraUpdate.newLatLng(position));
        }
      }
    });
  }

  void _toggleTracking() async {
    setState(() {
      isTracking = !isTracking;
    });
    await FirebaseFirestore.instance.collection('vehicles').doc(selectedLine).collection('vehicles').doc(vehicleName).update({
      'active': isTracking,
    });
    if (!isTracking) {
      _locationSubscription?.cancel();
    } else {
      _startTracking();
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vehicle Tracking Active')),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(target: LatLng(30.0444, 31.2357), zoom: 12),
            markers: _currentPosition != null
                ? {
              Marker(
                markerId: MarkerId(vehicleName ?? 'vehicle'),
                position: _currentPosition!,
                icon: _vehicleIcon ?? BitmapDescriptor.defaultMarker,
                infoWindow: InfoWindow(title: vehicleName),
              ),
            }
                : {},
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
          ),
          Positioned(
            bottom: 80,
            right: 20,
            child: FloatingActionButton(
              onPressed: _toggleTracking,
              backgroundColor: isTracking ? Colors.red : Colors.green,
              child: Icon(isTracking ? Icons.visibility_off : Icons.visibility),
            ),
          ),
        ],
      ),
    );
  }
}



