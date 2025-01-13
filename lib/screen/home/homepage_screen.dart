
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_sign/screen/customInfoScreen/customInfoMap.dart';

import '../excel_import/excel_import_screen.dart';

class HomePageScreen extends StatefulWidget {
  final String displayName;
  final String email;
  final String? photoURL;
  final String? latitude;
  final String? longitude;

  const HomePageScreen({
    super.key,
    required this.displayName,
    required this.email,
    required this.photoURL,
    required this.latitude,
    required this.longitude
  });

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  String address = "Loading address...";

  @override
  void initState() {
    super.initState();
    getAddressFromLatLng();
  }

  Future<void> getAddressFromLatLng() async {
    try {
      if (widget.latitude != null && widget.longitude != null) {
        double lat = double.parse(widget.latitude!);
        double lng = double.parse(widget.longitude!);

        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          setState(() {
            address = '''
             ${place.street}
             ${place.subLocality}
             ${place.locality}
             ${place.postalCode}
             ${place.country}
           ''';
          });
        }
      } else {
        setState(() {
          address = "Coordinates not available";
        });
      }
    } catch (e) {
      setState(() {
        address = "Error getting address: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.displayName),
        actions: [IconButton(onPressed: (){
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ExcelImportScreen(),
            ),
          );
        }, icon: const Icon(EvaIcons.arrowheadDown))],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display coordinates
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Coordinates: (${widget.latitude}, ${widget.longitude})',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            // Display address
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('Address:',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        address,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>  CustomInfoWindows(
                initialLatitude: double.parse(widget.latitude!),
                initialLongitude: double.parse(widget.longitude!),
                address: address,
              ),
            ),
          );
        },
        child: const Icon(EvaIcons.arrowheadDown),
      ),
    );
  }
}