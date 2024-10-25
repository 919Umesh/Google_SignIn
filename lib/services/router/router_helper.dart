



import 'package:flutter/material.dart';
import 'package:google_sign/screen/splash_screen/splash_screen.dart';
import 'package:google_sign/services/router/router_name.dart';
import 'package:page_transition/page_transition.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashScreenPath:
        return PageTransition(
          type: PageTransitionType.rightToLeft,
          child:  SplashScreen(),
        );


      default:
        return errorRoute();
    }
  }
  static Route<dynamic> errorRoute() {
    return PageTransition(
      type: PageTransitionType.rightToLeft,
      child: Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('ERROR ROUTE')),
      ),
    );
  }
}
