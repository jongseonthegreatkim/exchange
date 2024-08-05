import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'get_info.dart';
import '../main.dart';
import '../statics.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // 구글 로그인 함수
  Future<User?> signInWithGoogle() async {
    print('signInWithGoogle function is executed');

    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      print('GoogleSignIn progress in done.');

      // Check if the user canceled the sign-in
      if(googleUser == null) {
        print('User canceled the Google sign-in');
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      print('authentication Completed.');

      // Check if the authentication object is valid
      if(googleAuth == null || (googleAuth.accessToken == null && googleAuth.idToken == null)) {
        print('GoogleAuth is invalid or missing tokens.');
        return null;
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // Once signed in, return the userCredential.user
      return userCredential.user;
    } catch (e) {
      // Handle the error appropriately
      print('Error during Google Sign-In: $e');
      return null;
    }
  }

  // 애플 로그인 함수
  Future<User?> signInWithApple() async {
    try {
      final appleProvider = AppleAuthProvider();
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithProvider(appleProvider);
      return userCredential.user;
    } catch (e) {
      if(e is FirebaseAuthException && e.code == 'canceled') {
        print('User canceled the Apple sign-in.');
        return null;
      } else {
        print('Error during Apple Sign-In: $e');
        return null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 앱 제목
            Image.asset('assets/images/logo_login_screen.png', width: 200),
            Column(
              children: [
                // 구글 로그인 버튼
                googleLogin(context),
                // 애플 로그인 버튼
                appleLogin(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget googleLogin(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          User? user = await signInWithGoogle();

          // User canceled the sign-in
          if(user == null) {
            print('User canceled the sign-in or an error occurred.');
            return; // Return to the login screen without crashing
          }

          final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
          final data = doc.data();

          if(data == null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => GetInfo(user: user),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Home(username: doc['username'], university: doc['university'], bottomIndex: 0),
              ),
            );
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width / 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Image.asset('assets/images/login_google.png', width: 20, height: 20),
              Text("Google로 로그인"),
            ],
          ),
        ),
        style: ButtonStyle(
          padding: WidgetStateProperty.resolveWith((states) {
            return EdgeInsets.symmetric(horizontal: 15);
          }),
          // foregroundColor = TextStyle(color), overlayColor = color when overlayed
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            return Colors.black.withOpacity(0.8);
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            return AppColors.white;
          }),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            return Colors.grey.withOpacity(0.1);
          }),
        ),
      ),
    );
  }

  Widget appleLogin(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          User? user = await signInWithApple();

          if(user == null) {
            print('User canceled the sign-in or an error occurred.');
            return; // Return to the login screen without crashing
          }

          final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
          final data = doc.data();

          if(data == null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => GetInfo(user: user),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Home(username: doc['username'], university: doc['university'], bottomIndex: 0),
              ),
            );
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width / 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Image.asset('assets/images/login_apple.png', width: 20, height: 20),
              Text("Apple로 로그인"),
            ],
          ),
        ),
        style: ButtonStyle(
          padding: WidgetStateProperty.resolveWith((states) {
            return EdgeInsets.symmetric(horizontal: 15);
          }),
          // foregroundColor = TextStyle(color), overlayColor = color when overlayed
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            return Colors.black.withOpacity(0.8);
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            return AppColors.white;
          }),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            return Colors.grey.withOpacity(0.1);
          }),
        ),
      ),
    );
  }
}