// import 'package:eva_icons_flutter/eva_icons_flutter.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign/Authentication/google_authentication.dart';
// import 'package:google_sign/screen/home/homepage_screen.dart';
// import 'package:google_sign/screen/login/user_data.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_sign/utils/custom_Log.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   User? currentUser = FirebaseAuth.instance.currentUser;
//   final phoneController = TextEditingController();
//   bool isloading = false;
//
//   // Method to handle location permission and sign in
//   Future<void> handleSignInWithLocation(BuildContext context) async {
//     try {
//       setState(() {
//         isloading = true;
//       });
//
//       // First check location permission
//       bool hasPermission = await MyPermission.checkPermissions();
//
//       if (!hasPermission) {
//         // Show dialog explaining why location is needed
//         if (context.mounted) {
//           await showDialog(
//             context: context,
//             barrierDismissible: false,
//             builder: (BuildContext context) {
//               return AlertDialog(
//                 title: const Text('Location Permission Required'),
//                 content: const Text(
//                   'This app needs access to location to provide you with location-based services. '
//                       'Please grant location permission to continue.',
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                       setState(() {
//                         isloading = false;
//                       });
//                     },
//                     child: const Text('Cancel'),
//                   ),
//                   TextButton(
//                     onPressed: () async {
//                       Navigator.pop(context);
//                       // Try requesting permission again
//                       bool granted = await MyPermission.askPermissions();
//                       if (granted) {
//                         // If granted, proceed with sign in
//                         if (context.mounted) {
//                           await proceedWithSignIn(context);
//                         }
//                       } else {
//                         setState(() {
//                           isloading = false;
//                         });
//                       }
//                     },
//                     child: const Text('Grant Permission'),
//                   ),
//                 ],
//               );
//             },
//           );
//         }
//       } else {
//         // If permission is already granted, proceed with sign in
//         await proceedWithSignIn(context);
//       }
//     } catch (e) {
//       setState(() {
//         isloading = false;
//       });
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error during sign in: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
//
//   // Method for the actual sign in process
//   Future<void> proceedWithSignIn(BuildContext context) async {
//     try {
//       // Get current location
//       final location = MyLocation();
//       final latitude = await location.lat();
//       final longitude = await location.long();
//
//       // Proceed with Google Sign In
//       UserData? userData = await FirebaseAuthServices().signInWithGoogle();
//
//       if (userData != null) {
//         if (context.mounted) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => HomePageScreen(
//                 displayName: userData.displayName.toString(),
//                 email: userData.email.toString(),
//                 photoURL: userData.photoURL,
//                 latitude: latitude,
//                 longitude: longitude,
//               ),
//             ),
//           );
//         }
//       } else {
//         setState(() {
//           isloading = false;
//         });
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Sign-in failed or was cancelled.'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       setState(() {
//         isloading = false;
//       });
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error during sign in: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
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
//                       ],
//                     ),
//                     isloading
//                         ? const Center(
//                       child: CircularProgressIndicator(),
//                     )
//                         : InkWell(
//                       onTap: () => handleSignInWithLocation(context),
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
//
// // Location Permission Helper Class
// class MyPermission {
//   static Future<bool> askPermissions() async {
//     LocationPermission permission = await Geolocator.requestPermission();
//
//     CustomLog.actionLog(value: "Permission Status => $permission");
//     if (permission == LocationPermission.denied) {
//       return false;
//     } else if (permission == LocationPermission.deniedForever) {
//       return false;
//     } else {
//       return true;
//     }
//   }
//
//   static Future<bool> checkPermissions() async {
//     bool hasPermission = false;
//     await askPermissions().then((value) {
//       hasPermission = value;
//     });
//     return hasPermission;
//   }
// }
//
// // Location Helper Class
// class MyLocation {
//   Future<String> lat() async {
//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.medium,
//     );
//     return position.latitude.toString();
//   }
//
//   Future<String> long() async {
//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.medium,
//     );
//     return position.longitude.toString();
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

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  User? currentUser = FirebaseAuth.instance.currentUser;
  final phoneController = TextEditingController();
  bool isLoading = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> handleSignInWithLocation(BuildContext context) async {
    try {
      setState(() {
        isLoading = true;
      });

      bool hasPermission = await MyPermission.checkPermissions();

      if (!hasPermission) {
        if (context.mounted) {
          await showLocationPermissionDialog(context);
        }
      } else {
        await proceedWithSignIn(context);
      }
    } catch (e) {
      handleError(context, 'Error during sign in: $e');
    }
  }

  Future<void> showLocationPermissionDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Location Permission Required',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.blue,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'This app needs access to location to provide you with location-based services. '
                    'Please grant location permission to continue.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  isLoading = false;
                });
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                bool granted = await MyPermission.askPermissions();
                if (granted && context.mounted) {
                  await proceedWithSignIn(context);
                } else {
                  setState(() {
                    isLoading = false;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Grant Permission'),
            ),
          ],
        );
      },
    );
  }

  Future<void> proceedWithSignIn(BuildContext context) async {
    try {
      final location = MyLocation();
      final latitude = await location.lat();
      final longitude = await location.long();

      UserData? userData = await FirebaseAuthServices().signInWithGoogle();

      if (userData != null && context.mounted) {
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
      } else {
        handleError(context, 'Sign-in failed or was cancelled.');
      }
    } catch (e) {
      handleError(context, 'Error during sign in: $e');
    }
  }

  void handleError(BuildContext context, String message) {
    setState(() {
      isLoading = false;
    });
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    // App Logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade300, Colors.blue.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade100,
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.location_on,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Welcome Text
                    Text(
                      "Welcome Back",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Sign in to continue using the app",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Sign in Section
                    if (isLoading)
                      const CircularProgressIndicator()
                    else
                      _buildSignInButtons(),

                    const SizedBox(height: 40),

                    // Terms and Privacy
                    _buildTermsAndPrivacy(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButtons() {
    return Column(
      children: [
        _buildGoogleSignInButton(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade300)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "OR",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey.shade300)),
          ],
        ),
        const SizedBox(height: 16),
        _buildGuestButton(),
      ],
    );
  }

  Widget _buildGoogleSignInButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade700],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => handleSignInWithLocation(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  EvaIcons.googleOutline,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  "Continue with Google",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuestButton() {
    return TextButton(
      onPressed: () {
        // Implement guest login logic here
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(
        "Continue as Guest",
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTermsAndPrivacy() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            color: Colors.grey.shade600,
            height: 1.5,
          ),
          children: [
            const TextSpan(
              text: "By continuing, you agree to our ",
            ),
            TextSpan(
              text: "Terms of Service",
              style: TextStyle(
                color: Colors.blue.shade700,
                decoration: TextDecoration.underline,
              ),
            ),
            const TextSpan(text: " and "),
            TextSpan(
              text: "Privacy Policy",
              style: TextStyle(
                color: Colors.blue.shade700,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Keep existing MyPermission and MyLocation classes unchanged
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