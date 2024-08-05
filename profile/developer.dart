import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../statics.dart';

class Developer extends StatefulWidget {
  const Developer({super.key});

  @override
  State<Developer> createState() => _DeveloperState();
}

class _DeveloperState extends State<Developer> {
  // State variable that will contain data from Firestore
  Map<String, dynamic> developerData = {};
  Map<String, dynamic> helpersData = {};

  // 무한 future loading을 막기 위해서 fetchData에 대응하는 future를 하나 만든다.
  late Future<void> fetchDataFuture;

  @override
  void initState() {
    super.initState();
    fetchDataFuture = fetchData();
  }

  Future<void> fetchData() async {
    DocumentSnapshot<Map<String, dynamic>> developerSnapshot = await FirebaseFirestore.instance
        .collection('developer')
        .doc('개발진')
        .get();

    DocumentSnapshot<Map<String, dynamic>> helpersSnapshot = await FirebaseFirestore.instance
        .collection('developer')
        .doc('도움 주신 분들')
        .get();

    setState(() {
      developerData = developerSnapshot.data()!;
      helpersData = helpersSnapshot.data()!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _appBar(context),
      body: _body(context),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      scrolledUnderElevation: 0, // Disable light background color when we scroll body upward
      title: const Text('개발진 정보'),
      titleSpacing: 0, // To make title to stay at the middle
    );
  }

  Widget _body(BuildContext context) {
    return FutureBuilder(
      future: fetchDataFuture,
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.keyColor,
              backgroundColor: AppColors.white,
            ),
          );
        } else {
          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _developerProfileSection(),
                  const SizedBox(height: 20),
                  _developerContactSection(),
                  const SizedBox(height: 10),
                  _helperContactSection(),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _developerProfileSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey, width: 0.5),
        color: AppColors.white,
      ),
      child: Row(
        children: [
          Icon(Icons.person_pin_rounded, size: 80, color: AppColors.keyColor),
          const SizedBox(width: 20),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Team 2729', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('한양대학교', style: TextStyle(fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _developerContactSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("대학교환 공식 연락처", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          ...developerData.entries.map((entry) =>
            GestureDetector(
              onTap: () async {
                await _developerContactOnTap(entry.key, entry.value);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  entry.key,
                  style: const TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _developerContactOnTap(String key, String value) async {
    if(key == '인스타그램' || key == '카카오톡 오픈채팅') {
      Uri url = Uri.parse(value);
      await canLaunchUrl(url) ? launchUrl(url) : print('Launch failed: $url');
    }
    if(key == '메일') {
      Uri url = Uri(
        scheme: 'mailto',
        path: value,
      );
      await canLaunchUrl(url) ? launchUrl(url) : print('Mail app launch failed: $url');
    }
    if(key == '전화') {
      _showContactDialog(context, key, value);
    }
  }
  void _showContactDialog(BuildContext context, String key, String value) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: Text(key),
          content: Text(value),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                '확인',
                style: TextStyle(color: AppColors.keyColor, fontWeight: FontWeight.bold),
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

  Widget _helperContactSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("도움 주신 분들", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          ...helpersData.entries.map((entry) =>
            GestureDetector(
              onTap: () async {
                Uri url = Uri.parse(entry.value);
                await canLaunchUrl(url) ? launchUrl(url) : print('Launch failed: $url');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  '@${entry.key}',
                  style: const TextStyle(color: Colors.black45, fontSize: 17, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}