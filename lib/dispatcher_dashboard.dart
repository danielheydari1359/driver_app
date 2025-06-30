import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DispatcherDashboard extends StatefulWidget {
  const DispatcherDashboard({super.key});

  @override
  State<DispatcherDashboard> createState() => _DispatcherDashboardState();
}

class _DispatcherDashboardState extends State<DispatcherDashboard> {
  GoogleMapController? _mapController;
  LatLng? _driverLocation;
  Marker? _driverMarker;

  @override
  void initState() {
    super.initState();
    _listenToDriverLocation();
  }

  void _listenToDriverLocation() {
    FirebaseFirestore.instance
        .collection('drivers')
        .doc('driver_1')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        final lat = data['latitude'];
        final lng = data['longitude'];

        LatLng newLocation = LatLng(lat, lng);

        final updatedMarker = Marker(
          markerId: const MarkerId('driver'),
          position: newLocation,
          infoWindow: const InfoWindow(title: 'Driver'),
        );

        setState(() {
          _driverLocation = newLocation;
          _driverMarker = updatedMarker;
        });

        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(newLocation),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dispatcher View')),
      body: _driverLocation == null
          ? const Center(child: Text('Waiting for driver location...'))
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _driverLocation!,
                zoom: 16,
              ),
              markers: _driverMarker != null ? {_driverMarker!} : {},
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
    );
  }
}
