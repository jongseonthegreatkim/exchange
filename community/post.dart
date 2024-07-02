import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For user authentication
import 'package:intl/intl.dart';
import 'edit_post.dart';

Color backgroundColor = Color(0xFFF8F7F4);
Color conceptColor = Color(0xFF73A9DA);
Color conceptBackgroundColor = Color(0xFFF5DADA);
Color intermediateBackgroundColor = Color(0xFFfbfff8);

class Post extends StatefulWidget {
  const Post({super.key,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.userId,
    required this.documentId,
    required this.onPostFixed,
  });

  final String title;
  final String content;
  final DateTime timestamp;
  final String userId;
  final String documentId; // Unique document ID for the post
  final Function onPostFixed; // To refresh community.dart when we edit / delete the post

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {

  late String _currentTitle; // State variable for the title
  late String _currentContent; // State variable for the content

  @override
  void initState() {
    super.initState();
    // Initialize state variable with the widget's initial values
    _currentTitle = widget.title;
    _currentContent = widget.content;
  }

  @override
  Widget build(BuildContext context) {
    // Get the current user
    User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        scrolledUnderElevation: 0, // Disable light background color when we scroll body upward.
        title: Text('커뮤니티'),
        titleSpacing: 0,
        actions: [
          // Only show edit and delete buttons if the user is the author
          if(currentUser != null && currentUser.uid == widget.userId)...[
            IconButton(
              // use async keyword to wait for EditPost
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPost(
                      title: _currentTitle,
                      content: _currentContent,
                      documentId: widget.documentId,
                      onPostFixed: widget.onPostFixed,
                    ),
                  ),
                );

                // Check if the result is not null and contains updated data
                if(result != null && result is Map<String, String>) {
                 setState(() {
                   _currentTitle = result['title']!;
                   _currentContent = result['content']!;
                 });
                }
              },
              icon: Icon(Icons.edit, color: Colors.black),
            ),
            IconButton(
              onPressed: () {_showDeleteConfirmationDialog();},
              icon: Icon(Icons.delete_forever, color: Colors.black),
            ),
          ]
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView( // To make Post section and Comments section to be scrollable altogether.
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPostSection(), // Post
                    _buildCommentsListSection(), // Comments
                  ],
                ),
              ),
            ),
            _buildAddCommentSection(), // Add Comments
          ],
        ),
      ),
    );
  }

  Widget _buildPostSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_currentTitle, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 14),
          Text(_currentContent, style: TextStyle(fontSize: 18)),
          SizedBox(height: 14),
          Row(
            children: [
              Text(DateFormat('MM/dd HH:mm').format(widget.timestamp), style: TextStyle(fontSize: 16, color: Colors.black54)),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                width: 0.5,
                height: 10,
                color: Colors.black54,
              ),
              Text('익명', style: TextStyle(fontSize: 16, color: Colors.black54, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: Text("게시글 삭제"),
          content: Text("게시글을 삭제하시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                '취소',
                style: TextStyle(color: conceptColor, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                _deletePost();
                Navigator.of(context).pop(); // to community.dart
              },
              child: Text(
                '삭제',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          )
        );
      },
    );
  }

  Future<void> _deletePost() async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(widget.documentId)
        .delete();

      // Call the callback to refresh the community screen
      widget.onPostFixed();

      Navigator.of(context).pop(); // Go back to the previous screen (to a post.dart)

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Post deleted successfully!')));
    } catch (e) {
      print('Error deleting post: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete post. Please try again.')));
    }
  }

  // Fetching and displaying the comments list
  Widget _buildCommentsListSection() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.documentId) // Use the unique document ID
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .get(),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(
            color: conceptColor,
            backgroundColor: backgroundColor,
          ));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading comments'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('아직 댓글이 없습니다!'));
        } else {
          var comments = snapshot.data!.docs;

          // 여기서 글쓴이를 제외한 명 수를 계산해줘야 함. 그래서 이 값에서 빼주는 걸로 해야 할 듯.
          int numberOfCommenter = _getNumberOfCommenter(comments);

          return ListView.builder(
            physics: NeverScrollableScrollPhysics(), // Disable scrolling independently. It will be scrollable inside a SingleChildScrollView
            shrinkWrap: true, // Allow ListView to take only as much space as it needs.
            itemCount: comments.length,
            itemBuilder: (context, index) {
              var comment = comments[index];
              String content = comment['content'] ?? 'No Content';
              DateTime timestamp = (comment['timestamp'] as Timestamp).toDate();
              String userId = comment['userId'] ?? 'Anonymous';
              String anonymousId = _getAnonymousId(userId, numberOfCommenter);

              return _buildCommentsListCard(content, timestamp, anonymousId);
            },
          );
        }
      },
    );
  }

  int _getNumberOfCommenter(var comments) {

    int numberOfCommenter = 0;
    Set<String> commenterSet = {};

    for(var comment in comments) {
      var userId = comment['userId'];

      // 글쓴이도 아니고, 이미 작성한 이력이 있는 user도 아닌 경우에만 실행
      if(userId != widget.userId && !commenterSet.contains(userId)) {
        numberOfCommenter++;
        commenterSet.add(userId);
      }
    }

    return numberOfCommenter;
  }

  // First String is userId, second String is return value.
  Map<String, String> _anonymousIdMap = {};
  int _anonymousCounter = 0;

  String _getAnonymousId(String userId, int numberOfCommenter) {
    // Check if the user is the post author
    if(userId == widget.userId)
      return '익명(글쓴이)';

    // Check if the userId already got anonymousId
    if(_anonymousIdMap.containsKey(userId))
      return _anonymousIdMap[userId]!;

    // Otherwise, this userId is new in this post
    // Calculate how old commenter he/she is
    // If _anonymousCounter stays zero, it means, in this post, he/she is newest commenter.
    String temp = '익명${numberOfCommenter - _anonymousCounter}';
    _anonymousIdMap[userId] = temp;
    _anonymousCounter++;
    return temp;
  }

  Widget _buildCommentsListCard(String content, DateTime timestamp, String anonymousId) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.only(top: 15),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(width: 0.5, color: Colors.grey)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(content),
          Row(
            children: [
              Text(DateFormat('MM/dd HH:mm').format(timestamp), style: TextStyle(fontSize: 14, color: Colors.black38)),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                width: 0.5,
                height: 10,
                color: Colors.black38,
              ),
              Text(anonymousId, style: TextStyle(fontSize: 14, color: Colors.black38, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddCommentSection() {
    TextEditingController _commentController = TextEditingController();

    IconButton _suffixIconButton = IconButton(
      icon: Icon(Icons.send, color: conceptColor),
      onPressed: () async {
        String commentContent = _commentController.text.trim();

        // Get the current user
        User? user = FirebaseAuth.instance.currentUser;

        if (commentContent.isNotEmpty) {
          // Save the comment to Firestore
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(widget.documentId)
              .collection('comments')
              .add({
            'content': commentContent,
            'timestamp': Timestamp.now(),
            'userId': user?.uid,
          });

          // Clear the input field
          _commentController.clear();

          // Refresh the comments list
          setState(() {});
        }
      },
    );

    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _commentController,
              onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
              decoration: InputDecoration(
                hintText: '댓글을 입력하세요',
                border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: conceptColor)),
                contentPadding: EdgeInsets.only(left: 15),
                suffixIcon: _suffixIconButton,
              ),
            ),
          ),
        ],
      ),
    );
  }
}