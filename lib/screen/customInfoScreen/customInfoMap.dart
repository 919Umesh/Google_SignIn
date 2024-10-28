import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomInfoWindows extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;
  final String address;

  const CustomInfoWindows({
    super.key,
    required this.initialLatitude,
    required this.initialLongitude,
    required this.address,
  });

  @override
  State<CustomInfoWindows> createState() => _CustomInfoWindowsState();
}

class _CustomInfoWindowsState extends State<CustomInfoWindows> {
  final CustomInfoWindowController _customInfoWindowController =
  CustomInfoWindowController();
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    // Add a marker for the current location
    addCurrentLocationMarker();
  }

  void addCurrentLocationMarker() {
    markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        icon: BitmapDescriptor.defaultMarker,
        position: LatLng(widget.initialLatitude, widget.initialLongitude),
        onTap: () {
          // Show the custom info window for the current location
          _customInfoWindowController.addInfoWindow!(
            Container(
              color: Colors.white,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Location',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'This is your current location.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            LatLng(widget.initialLatitude, widget.initialLongitude),
          );
        },
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.address),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.initialLatitude, widget.initialLongitude),
              zoom: 15,
            ),
            markers: markers,
            onTap: (argument) {
              // Hide the custom info window when tapping the map
              _customInfoWindowController.hideInfoWindow!();
            },
            onCameraMove: (position) {
              // Update the custom info window's position when the camera moves
              _customInfoWindowController.onCameraMove!();
            },
            onMapCreated: (GoogleMapController controller) {
              // Set the GoogleMapController for the custom info window
              _customInfoWindowController.googleMapController = controller;
            },
          ),
          CustomInfoWindow(
            controller: _customInfoWindowController,
            height: 100, // Height of the custom info window
            width: 250, // Width of the custom info window
            offset: 35, // Offset to position the info window above the marker
          ),
        ],
      ),
    );
  }
}
