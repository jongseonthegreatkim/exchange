import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For user authentication

Color backgroundColor = Color(0xFFF8F7F4);
Color conceptColor = Color(0xFF73A9DA);
Color conceptBackgroundColor = Color(0xFFF5DADA);
Color intermediateBackgroundColor = Color(0xFFfbfff8);


class PostSubmissionScreen extends StatefulWidget {
  const PostSubmissionScreen({super.key, required this.onPostCreated});

  final Function onPostCreated; // Callback to refresh the community screen

  @override
  State<PostSubmissionScreen> createState() => _PostSubmissionScreenState();
}

class _PostSubmissionScreenState extends State<PostSubmissionScreen> {

  double _pageMargin = 16;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  Future<void> _submitPost() async {
    if(_formKey.currentState?.validate() ?? false) {
      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      // Create a new post
      await FirebaseFirestore.instance.collection('posts').add({
        'title' : _titleController.text,
        'content' : _contentController.text,
        'timestamp' : FieldValue.serverTimestamp(),
        'userId' : user?.uid ?? 'Anonymous', // Use user ID or 'Anonymous'
      });

      // Call the callback to refresh the community screen
      widget.onPostCreated();

      // Navigate back to the community screen
      Navigator.pop(context);
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        scrolledUnderElevation: 0,
        title: Text('새 글 쓰기'),
        centerTitle: true,
        actions: [
          // 작성 버튼
          GestureDetector(
            onTap: _submitPost,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: conceptColor,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '완료',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
          ),
          SizedBox(width: _pageMargin),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(_pageMargin),
        child: Form(
          key: _formKey,
          child: Column(
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
                // max&minLines allow to multi-line input rather than move old text into left side of screen.
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
                      '교환하냥은 모두가 건전하게 활동하는 커뮤니티를 지향합니다. '
                      '커뮤니티 가이드라인을 준수하지 않는 경우, 게시물이 삭제될 수 있습니다. '
                      '커뮤니티의 성격과 맞지 않는 정치/시사 주제의 게시물을 삼가 주시기 바랍니다. ',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
