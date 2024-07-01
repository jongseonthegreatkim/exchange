import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../main.dart';
import 'get_info.dart';

Color backgroundColor = Color(0xFFF8F7F4);
Color conceptColor = Color(0xFF73A9DA);
Color conceptBackgroundColor = Color(0xFFF5DADA);
Color intermediateBackgroundColor = Color(0xFFfbfff8);

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    return userCredential.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 앱 제목
            Column(
              children: [
                Row(
                  children: [
                    Expanded(flex: 2, child: SizedBox()),
                    Expanded(flex: 3, child: FittedBox(fit: BoxFit.fitWidth, child: Text(
                      '교환학생 준비는',
                    ))),
                    Expanded(flex: 2, child: SizedBox()),
                  ],
                ),
                Row(
                  children: [
                    Expanded(flex: 2, child: SizedBox()),
                    Expanded(flex: 3, child: FittedBox(fit: BoxFit.fitWidth, child: Text(
                      'Exchange',
                      style: TextStyle(fontWeight: FontWeight.bold, color: conceptColor),
                    ))),
                    Expanded(flex: 2, child: SizedBox()),
                  ],
                ),
              ],
            ),
            // 구글 로그인 버튼
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  User? user = await signInWithGoogle();

                  final doc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
                  final data = doc.data();

                  if(data == null) {
                    if (user != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GetInfo(user: user),
                        ),
                      );
                    }
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Home(username: doc['username'], university: doc['university']),
                      ),
                    );
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/google_logo.png', width: 20, height: 20),
                    SizedBox(width: 10),
                    Text("Google 계정으로 로그인"),
                  ],
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
                    return backgroundColor;
                  }),
                  overlayColor: WidgetStateProperty.resolveWith((states) {
                    return Colors.grey.withOpacity(0.1);
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}