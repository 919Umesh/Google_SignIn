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
            address = '''${place.street}
${place.subLocality}
${place.locality}
${place.postalCode}
${place.country}''';
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          widget.displayName,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ExcelImportScreen(),
                ),
              );
            },
            icon: const Icon(EvaIcons.downloadOutline, color: Colors.black87),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(widget.photoURL ??
                        'https://via.placeholder.com/150'),
                    backgroundColor: Colors.grey[200],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.email,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                elevation: 4,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.blue),
                          const SizedBox(width: 10),
                          Text(
                            'Location Details',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Text(
                        'Coordinates',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '(${widget.latitude}, ${widget.longitude})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Address',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        address,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CustomInfoWindows(
                initialLatitude: double.parse(widget.latitude!),
                initialLongitude: double.parse(widget.longitude!),
                address: address,
              ),
            ),
          );
        },
        icon: const Icon(EvaIcons.map),
        label: const Text('View Map'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}