import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../statics.dart';

class EditPost extends StatefulWidget {
  const EditPost({super.key, required this.title, required this.content, required this.documentId, required this.onPostFixed});

  final String title;
  final String content;
  final String documentId;
  final Function onPostFixed;

  @override
  State<EditPost> createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {

  double _pageMargin = 16;

  @override
  Widget build(BuildContext context) {
    // Pre-fill TextEditingController with existing title and content
    TextEditingController _titleController = TextEditingController(text: widget.title);
    TextEditingController _contentController = TextEditingController(text: widget.content);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        scrolledUnderElevation: 0, // Disable light background color when we scroll body upward
        title: Text('게시글 수정'),
        titleSpacing: 0, // To make title to stay at the middle
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.white,
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
              _editPost(_titleController.text, _contentController.text);

              // Pop 하면서 title과 content라는 Key를 만들어서 거기에 value를 담아 전달
              Navigator.of(context).pop({
                'title' : _titleController.text,
                'content' : _contentController.text,
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.keyColor,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '수정',
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
    );
  }

  Future<void> _editPost(String newTitle, String newContent) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(widget.documentId)
          .update({'title' : newTitle, 'content' : newContent});

      // Call the callback to refresh the community screen
      widget.onPostFixed();

      //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Post updated successfully!')));
    } catch (e) {
      print('Error updating post: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update post. Please try again.')));
    }
  }
}