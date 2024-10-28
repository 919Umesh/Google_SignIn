// import 'package:eva_icons_flutter/eva_icons_flutter.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign/Authentication/google_authentication.dart';
// import 'package:google_sign/screen/home/homepage_screen.dart';
// import 'package:google_sign/screen/login/user_data.dart';
//
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//
//   User? currentUser = FirebaseAuth.instance.currentUser;
//
//   final phoneController = TextEditingController();
//
//   bool isloading = false;
//   @override
//   Widget build(BuildContext context) {
//     User? currentUser = FirebaseAuth.instance.currentUser;
//     Size size = MediaQuery.of(context).size;
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         child: SafeArea(
//           bottom: false,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Center(
//                 child: Text(
//                   "Log in or sign up",
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               const Divider(
//                 color: Colors.black12,
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Container(
//                             height: 1,
//                             color: Colors.black26,
//                           ),
//                         ),
//
//                       ],
//                     ),
//                     InkWell(
//                       onTap: () async {
//                         UserData? userData = await FirebaseAuthServices().signInWithGoogle();
//                         if (userData != null) {
//                           Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => HomePageScreen(displayName: userData.displayName.toString(),email: userData.email.toString(),photoURL: userData.photoURL,), // Pass userData directly
//                             ),
//                           );
//                         } else {
//                           // Handle the case where userData is null (e.g., show an error message)
//                           print("Sign-in failed or was cancelled.");
//                         }
//                       },
//                       child: socialIcons(
//                         size,
//                         EvaIcons.googleOutline,
//                         "Continue with Google",
//                         Colors.pink,
//                         27,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Padding socialIcons(Size size, icon, name, color, double iconSize) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 15),
//       child: Container(
//         width: size.width,
//         padding: const EdgeInsets.symmetric(vertical: 11),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(),
//         ),
//         child: Row(
//           children: [
//             SizedBox(width: size.width * 0.05),
//             Icon(
//               icon,
//               color: color,
//               size: iconSize,
//             ),
//             SizedBox(width: size.width * 0.18),
//             Text(
//               name,
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const SizedBox(width: 10),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign/Authentication/google_authentication.dart';
import 'package:google_sign/screen/home/homepage_screen.dart';
import 'package:google_sign/screen/login/user_data.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign/utils/custom_Log.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  final phoneController = TextEditingController();
  bool isloading = false;

  // Method to handle location permission and sign in
  Future<void> handleSignInWithLocation(BuildContext context) async {
    try {
      setState(() {
        isloading = true;
      });

      // First check location permission
      bool hasPermission = await MyPermission.checkPermissions();

      if (!hasPermission) {
        // Show dialog explaining why location is needed
        if (context.mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Location Permission Required'),
                content: const Text(
                  'This app needs access to location to provide you with location-based services. '
                      'Please grant location permission to continue.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        isloading = false;
                      });
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      // Try requesting permission again
                      bool granted = await MyPermission.askPermissions();
                      if (granted) {
                        // If granted, proceed with sign in
                        if (context.mounted) {
                          await proceedWithSignIn(context);
                        }
                      } else {
                        setState(() {
                          isloading = false;
                        });
                      }
                    },
                    child: const Text('Grant Permission'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        // If permission is already granted, proceed with sign in
        await proceedWithSignIn(context);
      }
    } catch (e) {
      setState(() {
        isloading = false;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during sign in: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Method for the actual sign in process
  Future<void> proceedWithSignIn(BuildContext context) async {
    try {
      // Get current location
      final location = MyLocation();
      final latitude = await location.lat();
      final longitude = await location.long();

      // Proceed with Google Sign In
      UserData? userData = await FirebaseAuthServices().signInWithGoogle();

      if (userData != null) {
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePageScreen(
                displayName: userData.displayName.toString(),
                email: userData.email.toString(),
                photoURL: userData.photoURL,
                latitude: latitude,
                longitude: longitude,
              ),
            ),
          );
        }
      } else {
        setState(() {
          isloading = false;
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sign-in failed or was cancelled.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        isloading = false;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during sign in: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Log in or sign up",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(
                color: Colors.black12,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.black26,
                          ),
                        ),
                      ],
                    ),
                    isloading
                        ? const Center(
                      child: CircularProgressIndicator(),
                    )
                        : InkWell(
                      onTap: () => handleSignInWithLocation(context),
                      child: socialIcons(
                        size,
                        EvaIcons.googleOutline,
                        "Continue with Google",
                        Colors.pink,
                        27,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding socialIcons(Size size, icon, name, color, double iconSize) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        width: size.width,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(),
        ),
        child: Row(
          children: [
            SizedBox(width: size.width * 0.05),
            Icon(
              icon,
              color: color,
              size: iconSize,
            ),
            SizedBox(width: size.width * 0.18),
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}

// Location Permission Helper Class
class MyPermission {
  static Future<bool> askPermissions() async {
    LocationPermission permission = await Geolocator.requestPermission();

    CustomLog.actionLog(value: "Permission Status => $permission");
    if (permission == LocationPermission.denied) {
      return false;
    } else if (permission == LocationPermission.deniedForever) {
      return false;
    } else {
      return true;
    }
  }

  static Future<bool> checkPermissions() async {
    bool hasPermission = false;
    await askPermissions().then((value) {
      hasPermission = value;
    });
    return hasPermission;
  }
}

// Location Helper Class
class MyLocation {
  Future<String> lat() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );
    return position.latitude.toString();
  }

  Future<String> long() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );
    return position.longitude.toString();
  }
}