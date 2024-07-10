import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Color backgroundColor = Color(0xFFF8F7F4);
Color conceptColor = Color(0xFF73A9DA);
Color conceptBackgroundColor = Color(0xFFF5DADA);
Color intermediateBackgroundColor = Color(0xFFfbfff8);
class Report extends StatefulWidget {
  const Report({super.key});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {

  double _pageMargin = 16;

  @override
  Widget build(BuildContext context) {
    TextEditingController _titleController = TextEditingController();
    TextEditingController _contentController = TextEditingController();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        scrolledUnderElevation: 0, // Disable light background color when we scroll body upward
        title: Text('신고하기'),
        titleSpacing: 0, // To make title to stay at the middle
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: conceptColor, width: 1),
              ),
              child: Text(
                '취소',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
          ),
          SizedBox(width: _pageMargin),
          GestureDetector(
            onTap: () {
              _saveReport(_titleController.text, _contentController.text);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: conceptColor,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '제출',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
          ),
          SizedBox(width: _pageMargin),
        ],
      ),
      body: Container(
        width: double.infinity,
        margin: EdgeInsets.all(_pageMargin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              autofocus: true,
              onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
              decoration: InputDecoration(
                hintText: '제목',
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              ),
              cursorColor: Colors.black,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '제목을 입력해주세요!';
                }
                return null;
              },
            ),
            SizedBox(height: _pageMargin),
            TextFormField(
              controller: _contentController,
              onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
              decoration: InputDecoration(
                hintText: '내용을 입력해주세요',
                border: InputBorder.none,
                isDense: true,
              ),
              cursorColor: Colors.black,
              minLines: 5,
              maxLines: 10,
              keyboardType: TextInputType.multiline, // Make ready keyboard to multi-line text input (return/enter key)
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '내용을 입력해주세요!';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '부적절한 사용자의 게시글 제목 또는 내용을 적어서 신고해주십시오 '
                    '회원님의 신고사항은 바로 개발자에게 전달되게 됩니다. '
                    '신고사항에 대한 답변은 하루 이내로 회원님의 이메일로 전달 될 예정입니다. ',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveReport(String newTitle, String newContent) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      await FirebaseFirestore.instance.collection('reports').doc().set({
        'title' : newTitle,
        'content' : newContent,
        'uid' : uid,
        'timestamp' : FieldValue.serverTimestamp(),
      });

      Navigator.of(context).pop(); // 다시 profile.dart로 돌아감.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('회원님의 신고가 정상적으로 등록되었습니다.')));

    } catch (e) {
      print('Error during report: $e');
      Navigator.of(context).pop(); // 다시 profile.dart로 돌아감.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('신고가 실패하였습니다. 다시 시도해 주세요.')));
    }
  }
}
