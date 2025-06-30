import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class JobDetailMap extends StatelessWidget {
  final String title;
  final String description;
  final double latitude;
  final double longitude;

  const JobDetailMap({
    super.key,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    final LatLng jobLocation = LatLng(latitude, longitude);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: jobLocation,
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('job'),
                  position: jobLocation,
                  infoWindow: InfoWindow(title: title, snippet: description),
                ),
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(description),
          ),
        ],
      ),
    );
  }
}
