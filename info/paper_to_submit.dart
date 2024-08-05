import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../main.dart';
import '../statics.dart';

class PaperToSubmit extends StatefulWidget {
  const PaperToSubmit({super.key,
    required this.university,
    required this.leftoverPapers,
    required this.donePapers,
    required this.warnings,
    required this.icon,
  });

  final String university;
  final List<dynamic> leftoverPapers;
  final List<dynamic> donePapers;
  final List<dynamic> warnings;
  final Icon icon;

  @override
  State<PaperToSubmit> createState() => _PaperToSubmitState();
}

class _PaperToSubmitState extends State<PaperToSubmit> {
  // Lists of boolean variable that respectively correspond to 'leftoverPapers' & 'donePapers'
  late List<bool> falseList;
  late List<bool> trueList;

  @override
  void initState() {
    super.initState();
    // Initialize the falseList & trueList respectively with [length of leftoverPapers] falses & [length of donePapers] trues
    falseList = List<bool>.filled(widget.leftoverPapers.length, false);
    trueList = List<bool>.filled(widget.donePapers.length, true);
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> leftoverPapers = widget.leftoverPapers;
    List<dynamic> donePapers = widget.donePapers;
    List<dynamic> warnings = widget.warnings;
    Icon icon = widget.icon;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _appBar(context, leftoverPapers, donePapers, icon),
      body: _body(context, leftoverPapers, donePapers, warnings),
      floatingActionButton: _floatingActionButton(context, leftoverPapers, donePapers),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  AppBar _appBar(BuildContext context, List<dynamic> leftoverPapers, List<dynamic> donePapers, Icon icon) {
    return AppBar(
      backgroundColor: AppColors.white,
      scrolledUnderElevation: 0, // Disable light background color when we scroll body upward.
      automaticallyImplyLeading: false,
      title: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () async {
                await _updateAndReplace(leftoverPapers, donePapers);
              },
              child: Icon(Icons.arrow_back_ios_new_rounded),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(width: 10),
                Text('제출 해야 할 서류'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, List<dynamic> leftoverPapers, List<dynamic> donePapers, List<dynamic> warnings) {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            child: Text(
              '${widget.university}의 제출서류는 아래와 같습니다.\n'
              '준비한 서류들을 체크해 주세요!',
              style: TextStyle(
                color: Colors.black, fontSize: 19, fontWeight: FontWeight.normal,
              ),
            ),
          ),
          SizedBox(height: 10),
          // Document ListView
          ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: NeverScrollableScrollPhysics(),
            itemCount: leftoverPapers.length,
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                width: double.infinity,
                color: Colors.white,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      // Toggle boolean value in falseList
                      falseList[index] = !falseList[index];
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: falseList[index] ? AppColors.keyColor : Colors.grey,
                        size: 25,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          leftoverPapers[index],
                          style: TextStyle(
                            color: falseList[index] ? Colors.grey : Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: NeverScrollableScrollPhysics(),
            itemCount: donePapers.length,
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                width: double.infinity,
                color: Colors.white,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      // Toggle boolean value in trueList
                      trueList[index] = !trueList[index];
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: trueList[index] ? AppColors.keyColor : Colors.grey,
                        size: 25,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          donePapers[index],
                          style: TextStyle(
                            color: trueList[index] ? Colors.grey : Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20),
          FittedBox(
            child: Text(
              '${widget.university}의 주의사항은 아래와 같습니다.\n'
              '꼼꼼히 읽어봐 주세요!',
              style: TextStyle(
                color: Colors.black, fontSize: 19, fontWeight: FontWeight.normal,
              ),
            ),
          ),
          // Warning ListView
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: warnings.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            WidgetSpan(
                              child: Icon(
                                Icons.circle,
                                size: 8,
                                color: Colors.black,
                              ),
                              alignment: PlaceholderAlignment.middle,
                            ),
                            TextSpan(
                              text: "  ${warnings[index]}",
                              style: TextStyle(
                                color: Colors.black, fontSize: 16, fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  ElevatedButton _floatingActionButton(BuildContext context, List<dynamic> leftoverPapers, List<dynamic> donePapers) {
    return ElevatedButton(
      onPressed: () async {
        await _updateAndReplace(leftoverPapers, donePapers);
      },
      child: Text('확인 완료', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      style: ButtonStyle(
        padding: WidgetStateProperty.resolveWith((states) {
          return EdgeInsets.symmetric(horizontal: 30);
        }),
        // foregroundColor = TextStyle(color), overlayColor = color when overlayed
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          return Colors.black.withOpacity(0.8);
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          return AppColors.secondBackgroundColor;
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          return Colors.grey.withOpacity(0.1);
        }),
      ),
    );
  }

  Future<void> _updateAndReplace(List<dynamic> leftoverPapers, List<dynamic> donePapers) async {
    // Get uid & username & university
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    DocumentSnapshot uidSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    String username = uidSnapshot['username'];
    String university = uidSnapshot['university'];

    if(uid != null) {
      List<String> currentLeftoverPapers = [];

      // leftoverPapers의 체크 안 된 문서들을 필터링해서 currentLeftoverPapers 넣는다.
      for(int i=0; i<falseList.length; i++) {
        if(!falseList[i])
          currentLeftoverPapers.add(leftoverPapers[i]);
      }

      // donePapers의 체크 안 된 문서들을 필터링해서 currentLeftoverPapers 넣는다.
      for(int i=0; i<trueList.length; i++) {
        if(!trueList[i])
          currentLeftoverPapers.add(donePapers[i]);
      }

      // currentLeftoverPapers를 uid document 밑의 미준비서류 필드에 추가한다.
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        '미준비서류' : currentLeftoverPapers,
      });

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('유저 정보를 받아드리는데 실패했습니다. 제출 서류 체크를 다시 시도해 주세요!'),
        ),
      );
    }

    // Navigate to new_info.dart
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Home(
          username: username,
          university: university,
          bottomIndex: 0,
        ),
      ),
    );
  }
}
