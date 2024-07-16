import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../community/post.dart';

Color backgroundColor = Color(0xFFF8F7F4);
Color conceptColor = Color(0xFF73A9DA);
Color conceptBackgroundColor = Color(0xFFF5DADA);
Color intermediateBackgroundColor = Color(0xFFfbfff8);

class UserContent extends StatefulWidget {
  const UserContent({super.key, required this.isPost, required this.username, required this.university});

  final bool isPost;

  final String username; final String university;

  @override
  State<UserContent> createState() => _UserContentState();
}

class _UserContentState extends State<UserContent> {
  List<DocumentSnapshot> _userPosts = []; // post that user wrote
  List<DocumentSnapshot> _userReactions = []; // reactions that user wrote

  bool _isLoading = true;

  Future<void> _fetchUserContent() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    // Fetch user's posts
    final QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    // Fetch user's comments
    final QuerySnapshot commentsSnapshot = await FirebaseFirestore.instance
        .collectionGroup('comments') // Using collectionGroup to search in all comments subcollections
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    // Fetch user's replies
    final QuerySnapshot repliesSnapshot = await FirebaseFirestore.instance
        .collectionGroup('replies')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    // 한 게시글에 여러 리액션 했다고 게시글 여러 번 fetch하지 않게 하는 코드
    Set<String> titlesSet = {};
    List<DocumentSnapshot> temp = [];

    // 댓글 파트
    for(var comment in commentsSnapshot.docs) {
      var _parentSnapshot = await comment.reference.parent.parent!.get();
      var _title = _parentSnapshot['title'];

      // 새로운 제목이라면 (새 게시글에 대한 댓글이라면)
      if(!titlesSet.contains(_title)) {
        titlesSet.add(_title); // 그 제목을 제목검열세트에 추가하고
        temp.add(_parentSnapshot); // 해당 snapshot은 _userReactions 쪽으로 전달
      }
    }

    // 대댓글 파트
    for(var reply in repliesSnapshot.docs) {
      var _parentSnapshot = await reply.reference.parent.parent!.get();
      var _grandparentSnapshot = await _parentSnapshot.reference.parent.parent!.get();
      var _title = _grandparentSnapshot['title'];

      // 새로운 제목이라면 (새 게시글에 대한 대댓글이라면)
      if(!titlesSet.contains(_title)) {
        titlesSet.add(_title); // 그 제목을 제목검열세트에 추가하고
        temp.add(_grandparentSnapshot); // 해당 snapshot은 _userReactions 쪽으로 전달
      }
    }

    setState(() {
      _userPosts = postsSnapshot.docs; // 내가 쓴 글 업데이트
      _userReactions = temp; // 내가 댓글/대댓글 쓴 글 업데이트
      _isLoading = false;
    });
  }

  Future<void> _refreshContents() async {
    // This function is sent to post.dart and used with a name of onPostFixed()
    // Because this fuction is called when post is Fixed.
    setState(() {
      _userPosts.clear();
      _userReactions.clear();
    });
    await _fetchUserContent();
  }

  @override
  void initState() {
    _fetchUserContent(); // fetch user's content when initially draw the screen.
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    // isPost의 값에 따라, _usetContent에 _userPosts를 집어넣을 것인지 _userComments를 집어넣을 것인지 결정
    // _userContent[index]의 구성
    // 'title': 포스트의 제목
    // 'content': 포스트의 내용
    // 'userId': 포스트 작성자 ID
    // 'timestamp': 포스트 작성 시간
    List<DocumentSnapshot> _userContent = widget.isPost ? _userPosts : _userReactions;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        scrolledUnderElevation: 0, // Disable light background color when we scroll body upward.
        title: Text(widget.isPost ? '내가 쓴 글' : '내가 댓글 쓴 글'),
      ),
      body: _isLoading
      ? Center(child: CircularProgressIndicator(
        color: conceptColor,
        backgroundColor: backgroundColor,
      ))
      : Column(
        children: [
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _userContent.length,
              itemBuilder: (context, index) {
                var post = _userContent[index];

                String title = post['title'];
                String content = post['content'];
                DateTime timestamp = (post['timestamp'] as Timestamp).toDate();
                String userId = post['userId'];
                String documentId = post.id;

                return _buildPostCard(title, content, timestamp, userId, documentId);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(String title, String content, DateTime timestamp, String userId, String documentId) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) =>
          Post(
            title: title,
            content: content,
            timestamp: timestamp,
            userId: userId,
            documentId: documentId, // Pass the unique documentId (the name of document of each post) to distinguish each post
            onPostFixed: _refreshContents,
            username: widget.username,
            university: widget.university,
          ),
        ));
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 15, 10, 0),
        padding: EdgeInsets.fromLTRB(10, 15, 10, 0),
        decoration: BoxDecoration(border: Border(top: BorderSide(width: 0.5, color: Colors.grey))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis)),
            Text(
              content,
              style: TextStyle(fontSize: 16, color: Colors.black54, overflow: TextOverflow.ellipsis),
              maxLines: 2,
            ),
            SizedBox(height: 5),
            Text(DateFormat('MM/dd HH:mm').format(timestamp), style: TextStyle(fontSize: 14, color: Colors.black38)),
          ],
        ),
      ),
    );
  }
}