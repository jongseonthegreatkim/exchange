import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:exchange/login/login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'user_content.dart';
import 'suggestion.dart';
import 'report.dart';
import 'developer.dart';
import '../colors.dart';

class Profile extends StatefulWidget {
  final String username;
  final String university;

  Profile({super.key, required this.username, required this.university});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(), // 프로필 섹션
            SizedBox(height: 20),
            _buildSettingSection(), // 설정 섹션
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Text("내 프로필", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        //SizedBox(height: 10),
        _buildProfileCard(widget.username, widget.university),
        /*
        SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("프로필 완성하기", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text("3/6", style: TextStyle(fontSize: 17, color: Colors.black54)),
          ],
        ),
        SizedBox(height: 10),
        Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.grey,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 2,
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: conceptColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        SizedBox(
          height: 76,
          child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: [
              _buildProfileEditCard("희망 국가 등록", "교환학생을 가고 싶은 나라를 등록해주세요"),
              SizedBox(width: 10),
              _buildProfileEditCard("희망 학교 등록", "최대 3개까지 고를 수 있어요"),
            ],
          ),
        ),
        */
      ],
    );
  }
  Widget _buildProfileCard(String name, String university) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey, width: 0.5),
        color: AppColors.backgroundColor,
      ),
      child: Row(
        children: [
          Icon(Icons.person, size: 100, color: Colors.red),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text(university, style: TextStyle(fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildProfileEditCard(String title, String content) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey, width: 0.5),
        color: AppColors.backgroundColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(content, style: TextStyle(fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingCard("내 활동", ["내가 쓴 글", '내가 댓글 쓴 글']),
        SizedBox(height: 10),
        _buildSettingCard("계정 설정", ['로그아웃', '계정 삭제']),
        SizedBox(height: 10),
        _buildSettingCard("Contact Us", ['건의하기', '신고하기', '개발진']),
        SizedBox(height: 10),
        //_buildSettingCard("앱 설정", ["다크모드", "알림 설정", "앱 잠금"]),
      ],
    );
  }
  Widget _buildSettingCard(String title, List<String> contents) {
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
          backgroundColor: AppColors.backgroundColor,
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
          backgroundColor: AppColors.backgroundColor,
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