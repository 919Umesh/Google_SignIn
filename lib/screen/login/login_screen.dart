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