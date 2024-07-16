import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/data/latest.dart';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeRemoteConfig();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  initializeTimeZones();

  runApp(ExchangeStudentApp());
}

Future<void> initializeRemoteConfig() async {
  final remoteConfig = FirebaseRemoteConfig.instance;

  // Set default values
  await remoteConfig.setDefaults({
    'requiredMinimumVersion' : '1.5.0',
  });

  // Set configuration
  await remoteConfig.setConfigSettings(
    RemoteConfigSettings(
      fetchTimeout: Duration(minutes: 1),
      minimumFetchInterval: Duration(hours: 1),
    ),
  );

  // Fetch the values from Firebase Remote Config
  try {
    await remoteConfig.fetchAndActivate();
  } catch (e) {
    print('failed to fetch remote config values: $e');
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background 메시지 수신: ${message.messageId}');
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
  final String username; // 사용자 이름
  final String university; // 사용자 대학
  final int bottomIndex;

  Home({super.key, required this.username, required this.university, required this.bottomIndex});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late int _currentIndex; // bottomNavigationBar
  bool _isSearching = false; // search posts
  TextEditingController _searchController = TextEditingController(); // search posts
  String _searchField = ''; // search posts

  @override
  void initState() {
    _currentIndex = widget.bottomIndex;

    checkForUpdate();

    initializeFirebaseMessaging();

    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void checkForUpdate() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    final requiredVersion = remoteConfig.getString('requiredMinimumVersion');

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;

    if(isVersionLowerThan(currentVersion, requiredVersion)) {
      showUpdateDialog();
    }
  }

  bool isVersionLowerThan(String currentVersion, String requiredVersion) {
    List<String> currentParts = currentVersion.split('.');
    List<String> requiredParts = requiredVersion.split('.');

    for(int i=0; i<requiredParts.length; i++) {
      if(i >= currentParts.length) {
        return true;
      }
      int currentPart = int.parse(currentParts[i]);
      int requiredPart = int.parse(requiredParts[i]);

      if(currentPart < requiredPart) {
        return true;
      } else if(currentPart > requiredPart) {
        return false;
      }
    }
    return false;
  }

  String exchangeAppStoreURL = 'https://apple.co/4cukF8B';

  void showUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: Text('업데이트 해줘!'),
          content: Text(
            '새 버전 나왔는디.. 업데이트 한 번만 해 주슈\n'
            '어짜피 오늘은 그만보기 이런 기능 없어\n'
            '켤때마다 뜰거야 그니까 해줘',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                '취소',
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () async {
                Uri url = Uri.parse(exchangeAppStoreURL);
                await canLaunchUrl(url) ? launchUrl(url) : print('Launch failed: $url');
              },
              child: Text(
                '업데이트 하기',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: conceptColor,
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        );
      }
    );
  }

  void initializeFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission for iOS
    NotificationSettings settings = await messaging.requestPermission(
      alert: true, announcement: false, badge: true, carPlay: false,
      criticalAlert: false, provisional: false, sound: true,
    );

    if(settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if(settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message in the foreground!');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    // Handle messages when the app is opened from a terminated state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        /// Navigate to the specific screen in your app.
      }
    });

    // Get the token each time the application loads
    messaging.getToken().then((token) {
      print("FirebaseMessaging token: $token");
      // Save the token to Firestore if necessary
      saveTokenToFirestore(token);
    });
  }

  void saveTokenToFirestore(String? token) async {
    if (token != null) {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'fcmToken': token,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    Text _appBarTitle = Text('교환하냥');
    late var _appBarLeading;
    List<Widget> _appBarActions = [];

    if(_currentIndex == 0) {
      _appBarLeading = Padding(
        padding: EdgeInsets.only(left: 15),
        child: Image.asset('assets/images/logo.png', width: 30, height: 30),
      );
    }
    if(_currentIndex == 1) {
      _appBarTitle = Text('커뮤니티');
      _appBarLeading = _isSearching ? null : Icon(Icons.list_alt, size: 30, color: Colors.black);
      _appBarActions = _isSearching ? [
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(15),
            child: TextFormField(
              controller: _searchController,
              autofocus: true,
              onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
              decoration: InputDecoration(
                hintText: '게시글을 검색해보세요!',
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              ),
              cursorColor: Colors.black,
              onChanged: (field) {
                setState(() {
                  _searchField = field;
                });
              },
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 15),
          child: IconButton(
            onPressed: () {
              setState(() {
                _isSearching = false;
                _searchController.clear();
                _searchField = '';
              });
            },
            icon: Icon(Icons.close, size: 30, color: Colors.black),
          ),
        ),
      ] : [
        Padding(
          padding: EdgeInsets.only(right: 15),
          child: IconButton(
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
            icon: Icon(Icons.search, size: 30, color: Colors.black)),
        ),
      ];
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
        actions: _appBarActions
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
            // 다른데로 넘어갈 땐 항상 _isSearching 끄기
            _isSearching = false;
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
      return Community(username: widget.username, university: widget.university, searchField: _searchField);
    } else {
      return Profile(username: widget.username, university: widget.university);
    }
  }
}