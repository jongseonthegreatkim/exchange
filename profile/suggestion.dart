import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../colors.dart';

class Suggestion extends StatefulWidget {
  const Suggestion({super.key});

  @override
  State<Suggestion> createState() => _SuggestionState();
}

class _SuggestionState extends State<Suggestion> {

  double _pageMargin = 16;

  @override
  Widget build(BuildContext context) {
    TextEditingController _titleController = TextEditingController();
    TextEditingController _contentController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        scrolledUnderElevation: 0, // Disable light background color when we scroll body upward
        title: Text('건의하기'),
        titleSpacing: 0, // To make title to stay at the middle
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.keyColor, width: 1),
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
              _saveSuggestion(_titleController.text, _contentController.text);
              Navigator.of(context).pop(); // 다시 profile.dart로 돌아감.
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('회원님의 건의사항이 정상적으로 등록되었습니다!')));
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.keyColor.withOpacity(0.8),
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
                    '회원님의 건의사항은 바로 개발자에게 전달되게 됩니다. '
                    '건의사항에 대한 답변은 하루 이내로 회원님의 이메일로 전달 될 예정입니다. '
                    '서비스의 품질 개선을 위한 어떠한 의견도 열린 마음으로 받아들이고 있습니다. '
                    '서비스와 관련 없는 건의사항은 삭제 조치 될 수 있습니다. ',
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

  Future<void> _saveSuggestion(String newTitle, String newContent) async {
    final userEmail = FirebaseAuth.instance.currentUser!.email;

    try {
      await FirebaseFirestore.instance.collection('suggestions').doc().set({
        'title' : newTitle,
        'content' : newContent,
        'userEmail' : userEmail,
        'timestamp' : FieldValue.serverTimestamp(),
      });

      //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Post updated successfully!')));
    } catch (e) {
      print('Error during giving a suggestion: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('문의가 실패하였습니다. 다시 시도해 주세요.')));
    }
  }
}
