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
                    Expanded(flex: 3, child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Row(
                        children: [
                          Image.asset('assets/images/logo.png', width: 20, height: 20),
                          SizedBox(width: 5),
                          Text(
                            '교환하냥',
                            style: TextStyle(fontWeight: FontWeight.bold, color: conceptColor),
                          ),
                        ],
                      ),
                    )),
                    Expanded(flex: 2, child: SizedBox()),
                  ],
                ),
              ],
            ),
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

  Widget googleLogin(BuildContext context) {
    return Center(
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
        child: Container(
          width: MediaQuery.of(context).size.width / 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Image.asset('assets/images/google_logo.png', width: 20, height: 20),
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
            return backgroundColor;
          }),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            return Colors.grey.withOpacity(0.1);
          }),
        ),
      ),
    );
  }

  Future<User?> signInWithApple() async {
    final appleProvider = AppleAuthProvider();
    final UserCredential userCredential = await FirebaseAuth.instance.signInWithProvider(appleProvider);
    return userCredential.user;
  }

  void temp() async {
    final appleProvider = AppleAuthProvider();
    await FirebaseAuth.instance.signInWithProvider(appleProvider).then((value) {
      print(value.user?.email);
    }).onError((error, stackTrace) {
      print('Error: $error');
    });
  }

  Widget appleLogin(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          User? user = await signInWithApple();

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
        child: Container(
          width: MediaQuery.of(context).size.width / 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.apple, size: 20),
              //Image.asset('assets/images/apple_logo.png', width: 20, height: 20),
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
            return backgroundColor;
          }),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            return Colors.grey.withOpacity(0.1);
          }),
        ),
      ),
    );
  }
}