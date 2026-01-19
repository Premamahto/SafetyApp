import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/emergency_model.dart';

/// Live map screen showing emergency location
/// Displays victim's location on Google Maps
class LiveMapScreen extends StatefulWidget {
  final EmergencyModel emergency;

  const LiveMapScreen({super.key, required this.emergency});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  GoogleMapController? _mapController;
  late LatLng _emergencyLocation;

  @override
  void initState() {
    super.initState();
    _emergencyLocation = LatLng(
      widget.emergency.latitude,
      widget.emergency.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.navigation),
            onPressed: _openInGoogleMaps,
            tooltip: 'Open in Google Maps',
          ),
        ],
      ),
      body: Column(
        children: [
          // Emergency Info Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.emergency.userName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 18),
                      const SizedBox(width: 8),
                      Text(widget.emergency.userPhone),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _makeCall,
                        icon: const Icon(Icons.call, size: 18),
                        label: const Text('Call'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(widget.emergency.address),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Map
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _emergencyLocation,
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('emergency'),
                  position: _emergencyLocation,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
                  infoWindow: InfoWindow(
                    title: widget.emergency.userName,
                    snippet: 'Emergency Location',
                  ),
                ),
              },
              onMapCreated: (controller) {
                _mapController = controller;
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
            ),
          ),

          // Coordinates Info
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text(
                      'Latitude',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(widget.emergency.latitude.toStringAsFixed(6)),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      'Longitude',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(widget.emergency.longitude.toStringAsFixed(6)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Open location in Google Maps app
  Future<void> _openInGoogleMaps() async {
    final url = Uri.parse(widget.emergency.googleMapsLink);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  /// Make call to victim
  Future<void> _makeCall() async {
    final url = Uri(scheme: 'tel', path: widget.emergency.userPhone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
