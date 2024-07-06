import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'login/login.dart';
import 'login/get_info.dart';
import 'info/info.dart';
import 'community/community.dart';
import 'profile/profile.dart';

Color backgroundColor = Color(0xFFF8F7F4);
Color conceptColor = Color(0xFF73A9DA);
Color conceptBackgroundColor = Color(0xFFF5DADA);
Color intermediateBackgroundColor = Color(0xFFfbfff8);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ExchangeStudentApp());
}

class ExchangeStudentApp extends StatelessWidget {
  const ExchangeStudentApp({super.key});

  Future<Map<String, String?>> _getUserInfoFromFirestore(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();

    if(data != null) {
      return {'uid': data['uid'], 'email': data['email'], 'username': data['username'], 'university': data['university']};
    }
    return {'username': null, 'university': null};
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: FirebaseAuth.instance.authStateChanges().first, // Get the current user state
        builder: (context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator(
                color: conceptColor,
                backgroundColor: backgroundColor,
              )),
            );
          } else if (snapshot.hasData) {
            final User user = snapshot.data!;
            return FutureBuilder<Map<String, String?>>(
              future: _getUserInfoFromFirestore(user.uid),
              builder: (context, firestoreSnapshot) {
                if (firestoreSnapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(
                    body: Center(child: CircularProgressIndicator(
                      color: conceptColor,
                      backgroundColor: backgroundColor,
                    )),
                  );
                } else {
                  final userInfo = firestoreSnapshot.data;
                  if (userInfo?['username'] == null || userInfo?['university'] == null) {
                    // User is logged in but needs to enter additional information
                    return GetInfo(user: user);
                  } else {
                    // User is logged in and has their data stored in Firestore
                    return Home(username: userInfo!['username']!, university: userInfo['university']!);
                  }
                }
              },
            );
          } else {
            // User is not logged in
            return Login();
          }
        },
      ),
    );
  }
}

class Home extends StatefulWidget {
  final String username;
  final String university;

  Home({super.key, required this.username, required this.university});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {

    Text _appBarTitle = Text('교환하냥');
    late var _appBarLeading;

    if(_currentIndex == 0) {
      _appBarLeading = Padding(
        padding: EdgeInsets.only(left: 15),
        child: Image.asset(
          'assets/images/logo.png', width: 30, height: 30,
        ),
      );
    }
    if(_currentIndex == 1) {
      _appBarTitle = Text('커뮤니티');
      _appBarLeading = Icon(Icons.list_alt, size: 30, color: Colors.black);
    }
    if(_currentIndex == 2) {
      _appBarTitle = Text('프로필');
      _appBarLeading = Icon(Icons.person, size: 30, color: Colors.black);
    };

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        scrolledUnderElevation: 0, // Disable light background color when we scroll body upward.
        leading: _appBarLeading,
        title: _appBarTitle,
        titleSpacing: _currentIndex == 0 ? 11 : 0,
        centerTitle: false,
        /*
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          /*
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            onPressed: () {},
          ),
          */
        ],

         */
      ),
      body: _body(context, _currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: backgroundColor,
        items: [
          BottomNavigationBarItem(icon: SizedBox(height: 30, child: Icon(Icons.school, size: 30)), label: '메인'),
          BottomNavigationBarItem(icon: SizedBox(height: 30, child: Icon(Icons.list_alt, size: 30)), label: '커뮤니티'),
          BottomNavigationBarItem(icon: SizedBox(height: 30, child: Icon(Icons.person, size: 30)), label: '개인정보'),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  Widget _body(BuildContext context, int index) {
    if (index == 0) {
      return Info(university: widget.university);
    } else if (index == 1) {
      return Community();
    } else {
      return Profile(username: widget.username, university: widget.university);
    }
  }
}
