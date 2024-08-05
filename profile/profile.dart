import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:exchange/login/login.dart';
import '../login/nation_select.dart';
import 'user_content.dart';
import 'suggestion.dart';
import 'report.dart';
import 'developer.dart';
import '../statics.dart';

class Profile extends StatefulWidget {
  final String username;
  final String university;

  Profile({super.key, required this.username, required this.university});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // 선택한 nations를 저장할 변수.
  List<String> selectedNations = [];

  // uid 문서의 nations 필드의 정보를 가져오는 함수
  Future<void> fetchNations() async {
    // 현재 사용자의 uid를 받아옴
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    // uid 존재 여부를 위해서 try-catch 문을 사용
    try{
      // uid 문서에 접근
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      // uid 문서를 Map<String, dynamic>으로 처리
      Map<String, dynamic>? data = userSnapshot.data() as Map<String, dynamic>?;
      // Map<String, dynamic>으로 처리된 uid 문서의 nations 필드를 List<dynamic>으로 처리해 nations에 넣는다.
      List<dynamic>? nations = data?['nations'] as List<dynamic>?;
      // nations가 존재하는 경우에만, selectedNations에 요소를 String으로 바꿔 전달한다.
      if(nations != null) {
        nations.forEach((element) {
          selectedNations.add(element.toString());
        });
      }

    } catch (e) {
      print('Error fetching nations field: $e');
    }
  }


  // fetchNations에 해당하는 Future
  late Future<void> nationsFuture;

  @override
  void initState() {
    super.initState();
    nationsFuture = fetchNations();
  }

  @override
  Widget build(BuildContext context) {
    // nationsFuture가 작동한 뒤에 UI를 그리자.
    return FutureBuilder(
      future: nationsFuture,
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: AppLoading.CPI,
          );
        } else {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _profileCard(), // 프로필 섹션
                  _nationsCard(), // 희망대학 섹션
                  _settingSection(), // 설정 섹션
                ],
              ),
            ),
          );
        }
      },
    );
  }
  Widget _profileCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: AppNumbers.profileInterSectionMargin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey, width: 0.5),
        color: AppColors.white,
      ),
      child: Row(
        children: [
          Icon(Icons.person, size: 80, color: AppColors.keyColor),
          SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.username, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text(widget.university, style: TextStyle(fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }
  Widget _nationsCard() {
    // nations 필드가 존재하지 않거나, 비었을 때
    /// 희망국가 선택하기 버튼 만들자. -> nation_select로 이동하는데, selectedNations 넘겨주지 않는다.
    if(selectedNations.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('교환 희망국가', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: FittedBox(
                      child: Text('아직 희망국가 선택을 하지 않았어요', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>
                        NationSelect(
                          username: widget.username,
                          university: widget.university,
                          from: 'profile',
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.secondBackgroundColor.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        '희망국가 선택하기',
                        style: TextStyle(color: Colors.black, fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // nations 필드가 존재하고, 비지 않았을 때

    // 보여질 희망국가 스트링
    String printingSelectedNations = '';

    if(selectedNations.length <= 3) {
      selectedNations.forEach((nation) {
        printingSelectedNations += nation + ', ';
      });

      // 마지막 컴마 없애기
      if(printingSelectedNations.isNotEmpty)
        printingSelectedNations = printingSelectedNations.substring(0, printingSelectedNations.length -2);

    } else {
      // 3개로만 자르기
      List<String> shortedSelectedNations = selectedNations.sublist(0, 3);

      shortedSelectedNations.forEach((nation) {
        printingSelectedNations += nation + ', ';
      });

      // 마지막 컴마 없애기 + '외 몇 곳' 추가하기
      if(printingSelectedNations.isNotEmpty) {
        printingSelectedNations = printingSelectedNations.substring(0, printingSelectedNations.length -2);
        printingSelectedNations += ' 외 ${selectedNations.length - 3}곳';
      }
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('교환 희망국가', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(printingSelectedNations, style: TextStyle(fontSize: 16)),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                      NationSelect(
                        username: widget.username,
                        university: widget.university,
                        selectedNations: selectedNations,
                        from: 'profile',
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.secondBackgroundColor.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: Text(
                      '희망국가 변경하기',
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _settingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _settingCard("내 활동", ["내가 쓴 글", '내가 댓글 쓴 글']),
        _settingCard("계정 설정", ['로그아웃', '계정 삭제']),
        _settingCard("Contact Us", ['건의하기', '신고하기', '개발진']),
      ],
    );
  }
  Widget _settingCard(String title, List<String> contents) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ...contents.map((content) =>
            GestureDetector(
              onTap: () async {
                if(content == '내가 쓴 글') {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => UserContent(isPost: true, username: widget.username, university: widget.university)));
                } else if(content == '내가 댓글 쓴 글') {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => UserContent(isPost: false, username: widget.username, university: widget.university)));
                } else if(content == '로그아웃') {
                  _showLogoutDialog(context); // show the confirmation dialog
                } else if(content == '계정 삭제') {
                  _showDeleteAccountDialog(context); // show the confirmation dialog
                } else if(content == '건의하기') {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Suggestion()));
                } else if(content == '신고하기') {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Report()));
                } else if(content == '개발진') {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Developer()));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('기능 준비 중입니다!')));
                }
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(content, style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: Text('로그아웃'),
          content: Text('정말 로그아웃 할 거에요..?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                '취소',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Perform the logout and navigation
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
              child: Text(
                '로그아웃',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: Text('계정 삭제'),
          content: Text(
            '계정을 삭제 하시면,\n작성하신 게시글 및 댓글에\n더 이상 접근 및 수정이 불가능합니다.'
            '\n그래도 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'
            '\n삭제를 위해서 재 로그인이 필요합니다.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                '취소',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () async {
                User? user = FirebaseAuth.instance.currentUser;

                /// 재인증 코드 넣기

                if(user != null) {
                  try {
                    // Re-Authentication
                    if (user.providerData.any((info) => info.providerId == 'google.com')) {
                      // Google re-authentication
                      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
                      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

                      AuthCredential credential = GoogleAuthProvider.credential(
                        accessToken: googleAuth.accessToken,
                        idToken: googleAuth.idToken,
                      );

                      await user.reauthenticateWithCredential(credential);
                    } else if (user.providerData.any((info) => info.providerId == 'apple.com')) {
                      // Apple re-authentication
                      final appleProvider = AppleAuthProvider();

                      await user.reauthenticateWithProvider(appleProvider);
                    }

                    await user.delete(); // Delete the user

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  } catch (e) {
                    print('Error deleting user: $e');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('계정 삭제 중 문제가 발생했습니다. 다시 시도해 주세요.')));
                  }
                }
              },
              child: Text(
                '계정 삭제',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        );
      },
    );
  }
}