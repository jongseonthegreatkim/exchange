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
  const UserContent({super.key, required this.isPost});

  final bool isPost;

  @override
  State<UserContent> createState() => _UserContentState();
}

class _UserContentState extends State<UserContent> {
  List<DocumentSnapshot> _userPosts = []; // post that user wrote
  List<DocumentSnapshot> _userComments = []; // comment that user wrote
  List<String> _userRef = []; // _userComments의 post title

  bool _isLoading = true;

  Future<void> _fetchUserContent() async {
    final user = FirebaseAuth.instance.currentUser!;

    final userId = user.uid;

    // Fetch user's post orderd by timestamp
    final QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    // Fetch user's comment and its post title
    final QuerySnapshot commentsSnapshot = await FirebaseFirestore.instance
        .collectionGroup('comments') // Using collectionGroup to search in all comments subcollections
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    for(var comment in commentsSnapshot.docs) {
      // Get the parent post's document ID from the comment's reference path
      var parentSnapshot = await comment.reference.parent.parent!.get();
      var theTitle = parentSnapshot['title'] ?? 'No Title';
      _userRef.add(theTitle);
    }

    setState(() {
      _userPosts = postsSnapshot.docs;
      _userComments = commentsSnapshot.docs;
      _isLoading = false;
    });
  }

  Future<void> _refreshContents() async {
    // This function is sent to post.dart and used with a name of onPostFixed()
    // Because this fuction is called when post is Fixed.
    setState(() {
      _userPosts.clear();
      _userComments.clear();
      _userRef.clear();
    });
    await _fetchUserContent();
  }

  @override
  void initState() {
    super.initState();
    _fetchUserContent(); // fetch user's content when initially draw the screen.

  }

  @override
  Widget build(BuildContext context) {

    // isPost의 값에 따라, _usetContent에 _userPosts를 집어넣을 것인지 _userComments를 집어넣을 것인지 결정
    List<DocumentSnapshot> _userContent = widget.isPost == true ? _userPosts : _userComments;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        scrolledUnderElevation: 0, // Disable light background color when we scroll body upward.
        title: Text(widget.isPost == true ? '내 게시물' : '내 댓글'),
      ),
      body: _isLoading
      ? Center(child: CircularProgressIndicator(
        color: conceptColor,
        backgroundColor: backgroundColor,
      ))
      : SafeArea(
        child: Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _userContent.length,
            itemBuilder: (context, index) {
              var post = _userContent[index];

              // Conditionally define title based on widget.isPost
              String title;
              if (widget.isPost) {
                title = post['title'] ?? 'No Title';
              } else {
                title = _userRef[index]; // Use the parent post title from _userRef
              }

              String content = post['content'] ?? 'No Content';
              DateTime timestamp = (post['timestamp'] as Timestamp).toDate();
              String userId = post['userId'] ?? 'Anonymous';
              String documentId = post.id;

              return _buildContentCard(title, content, timestamp, userId, documentId);
            },
          ),
        )
      ),
    );
  }

  // Word 'content' is used as it might be post or comment
  Widget _buildContentCard(String title, String content, DateTime timestamp, String userId, String documentId) {
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
            Text(DateFormat('MM/dd hh:mm').format(timestamp), style: TextStyle(fontSize: 14, color: Colors.black38)),
          ],
        ),
      ),
    );
  }
}