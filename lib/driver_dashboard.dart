import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  StreamSubscription<Position>? positionStream;
  bool locationDeniedForever = false;
  bool isLoading = true;
  Position? currentPosition;

  @override
  void initState() {
    super.initState();
    _checkAndStartLocationUpdates();
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  Future<void> _checkAndStartLocationUpdates() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

    if (!serviceEnabled ||
        permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        locationDeniedForever = true;
        isLoading = false;
      });
      return;
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((Position position) {
        setState(() {
          currentPosition = position;
          isLoading = false;
        });

        _uploadLocation(position.latitude, position.longitude);
      });
    }
  }

  void _uploadLocation(double lat, double lng) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('drivers').doc(user.uid).set({
      'location': {'lat': lat, 'lng': lng},
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (locationDeniedForever) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Location permission is permanently denied.\nPlease enable it from device settings.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Driver Dashboard')),
      body: Center(
        child: currentPosition == null
            ? const Text('Fetching location...')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Live Location'),
                  Text('Lat: ${currentPosition!.latitude}'),
                  Text('Lng: ${currentPosition!.longitude}'),
                  const SizedBox(height: 20),
                  const Text('Map not available in web preview.'),
                ],
              ),
      ),
    );
  }
}
