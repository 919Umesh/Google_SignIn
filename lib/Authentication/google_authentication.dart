import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign/screen/login/user_data.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthServices {
  final auth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn();

  signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
        final AuthCredential authCredential = GoogleAuthProvider.credential(accessToken: googleSignInAuthentication.accessToken, idToken: googleSignInAuthentication.idToken);
        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(authCredential);
        debugPrint(userCredential.user?.photoURL);
        debugPrint(userCredential.user?.displayName);
        debugPrint(userCredential.user?.email);
        await auth.signInWithCredential(authCredential);

        return UserData(
          displayName: userCredential.user?.displayName,
          email: userCredential.user?.email,
          photoURL: userCredential.user?.photoURL,
          uid: userCredential.user?.uid,
          latitude: "",
          longitude: "",
        );
      }
    } on FirebaseAuthException catch (e) {
      print(e.toString());
    }
  }



}
