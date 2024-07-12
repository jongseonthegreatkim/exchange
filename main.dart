import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/data/latest.dart';
import 'firebase_options.dart';
import 'login/login.dart';
import 'login/get_info.dart';
import 'info/info.dart';
import 'community/community.dart';
import 'profile/profile.dart';
import 'notification.dart'; // For flutter_local_notification -> foreground notification
import 'package:firebase_messaging/firebase_messaging.dart';

Color backgroundColor = Color(0xFFF8F7F4);
Color conceptColor = Color(0xFF73A9DA);
Color conceptBackgroundColor = Color(0xFFF5DADA);
Color intermediateBackgroundColor = Color(0xFFfbfff8);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // FCM
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // 권한 요청
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }

  // foreground notification 초기화
  await FlutterLocalNotification.init();

  // 백그라운드 메시지 핸들러 설정
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(ExchangeStudentApp());
}

// 백그라운드 메시지 핸들러
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');

  FlutterLocalNotification.showNotification(
      message.notification?.title ?? 'No Title',
      message.notification?.body ?? 'No Body'
  );
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
            return Scaffold(body: Center(child: CircularProgressIndicator(color: conceptColor, backgroundColor: backgroundColor)));
          } else if (snapshot.hasData) {
            final User user = snapshot.data!;
            return FutureBuilder<Map<String, String?>>(
              future: _getUserInfoFromFirestore(user.uid),
              builder: (context, firestoreSnapshot) {
                if (firestoreSnapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(body: Center(child: CircularProgressIndicator(
                    color: conceptColor,
                    backgroundColor: backgroundColor,
                  )));
                } else {
                  final userInfo = firestoreSnapshot.data;
                  if (userInfo?['username'] == null || userInfo?['university'] == null) {
                    // User is logged in but needs to enter additional information
                    return GetInfo(user: user);
                  } else {
                    // User is logged in and has their data stored in Firestore
                    return Home(username: userInfo!['username']!, university: userInfo['university']!, bottomIndex: 0);
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
  final int bottomIndex;

  Home({super.key, required this.username, required this.university, required this.bottomIndex});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late int _currentIndex;

  void _setupFCM() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    // Get the FCM token
    String? token = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $token');

    // Save the token to Firestore or your server if needed
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'fcmToken' : token,
    });

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        FlutterLocalNotification.showNotification(
            message.notification?.title ?? 'No Title',
            message.notification?.body ?? 'No Body'
        );
      }
    });

    // Listen to background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  @override
  void initState() {
    _currentIndex = widget.bottomIndex;

    // foreground push notification
    FlutterLocalNotification.init();
    Future.delayed(
      const Duration(seconds: 2),
      FlutterLocalNotification.requestNotificationPermission(),
    );

    // scheduled push notification (= background & terminated push notification)
    initializeTimeZones();

    // Get FCM Token of user and store it in Firestore.
    _setupFCM();

    super.initState();
  }

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
      return Community(username: widget.username, university: widget.university);
    } else {
      return Profile(username: widget.username, university: widget.university);
    }
  }
}
