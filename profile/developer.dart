import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Color backgroundColor = Color(0xFFF8F7F4);
Color conceptColor = Color(0xFF73A9DA);
Color conceptBackgroundColor = Color(0xFFF5DADA);
Color intermediateBackgroundColor = Color(0xFFfbfff8);

class Developer extends StatefulWidget {
  const Developer({super.key});

  @override
  State<Developer> createState() => _DeveloperState();
}

class _DeveloperState extends State<Developer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        scrolledUnderElevation: 0, // Disable light background color when we scroll body upward
        title: Text('개발진 정보'),
        titleSpacing: 0, // To make title to stay at the middle
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _developerProfile(), // 프로필 섹션
              SizedBox(height: 20),
              _developerInfo(), // 개인정보 섹션
            ],
          ),
        ),
      ),
    );
  }

  Widget _developerProfile() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey, width: 0.5),
        color: intermediateBackgroundColor,
      ),
      child: Row(
        children: [
          Icon(Icons.person, size: 100, color: conceptColor),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('김종선', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('한양대학교', style: TextStyle(fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _developerInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard("개발진 연락처", ['카카오톡 오픈프로필', '인스타그램', '전화', '메일']),
        SizedBox(height: 10),
        _buildHelperInfoCard('도움 주신 분들', ['yiyoonchul', 'hakjaee_204', 'dlrkqfh']),
      ],
    );
  }

  Widget _buildInfoCard(String title, List<String> contents) {
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
                  if(content == '카카오톡 오픈프로필') {
                    Uri url = Uri.parse('https://open.kakao.com/o/srhnKkBg');
                    await canLaunchUrl(url) ? launchUrl(url) : print('Launch failed: $url');
                  } else if(content == '인스타그램') {
                    Uri url = Uri.parse('https://www.instagram.com/exchange_univ/');
                    await canLaunchUrl(url) ? launchUrl(url) : print('Launch failed: $url');
                  } else if(content == '전화') {
                    _showPhoneDialog(context);
                  } else if(content == '메일') {
                    _showMailDialog(context);
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

  void _showPhoneDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: Text('개발진 대표 전화번호'),
          content: Text('010-2658-4379'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                '확인',
                style: TextStyle(color: conceptColor, fontWeight: FontWeight.bold),
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

  void _showMailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: Text('개발진 대표 메일'),
          content: Text('crushgagarin1961@naver.com'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                '확인',
                style: TextStyle(color: conceptColor, fontWeight: FontWeight.bold),
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

  Widget _buildHelperInfoCard(String title, List<String> contents) {
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
                if(content == 'yiyoonchul') {
                  Uri url = Uri.parse('https://www.instagram.com/yiyoonchul/');
                  await canLaunchUrl(url) ? launchUrl(url) : print('Launch failed: $url');
                } else if(content == 'hakjaee_204') {
                  Uri url = Uri.parse('https://www.instagram.com/hakjaee_204/');
                  await canLaunchUrl(url) ? launchUrl(url) : print('Launch failed: $url');
                } else if(content == 'dlrkqfh') {
                  Uri url = Uri.parse('https://www.instagram.com/dlrkqfh/');
                  await canLaunchUrl(url) ? launchUrl(url) : print('Launch failed: $url');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('기능 준비 중입니다!')));
                }
              },
              child: Row(
                children: [
                  Image.asset('assets/images/instagram_logo.png', width: 20),
                  SizedBox(width: 10),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(content, style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}