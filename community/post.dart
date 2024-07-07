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

  bool _isFetching = true;
  late Future<List<DocumentSnapshot>> _reactionsFuture; // Exist for prevent infinite re-building the UI

  List<DocumentSnapshot> _comments = [];

  String? _replyToCommentId; // Track the comment ID being replied to (used to store in Firestore)

  @override
  void initState() {
    super.initState();
    // Initialize state variable with the widget's initial values
    _currentTitle = widget.title;
    _currentContent = widget.content;
    _reactionsFuture = _fetchReactions();
  }

  Future<List<DocumentSnapshot>> _fetchReactions() async {
    try{
      setState(() {
        _isFetching = true;
      });

      List<DocumentSnapshot> allReactions = [];

      // Fetch comments
      QuerySnapshot commentSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.documentId)
          .collection('comments')
          .orderBy('timestamp', descending: false) // Fetch oldest first
          .get();

      allReactions.addAll(commentSnapshot.docs);

      /*
    for(var cs in allReactions) {
      print('Completed Comment Part: ${cs['userId'].toString().substring(0, 5)}');
    }
    */

      // Fetch replies for each comment
      for (var comment in commentSnapshot.docs) {
        QuerySnapshot replySnapshot = await comment.reference
            .collection('replies')
            .orderBy('timestamp', descending: false) // Fetch oldest first
            .get();

        allReactions.addAll(replySnapshot.docs);
      }

      // Sort all reactions by timestamp
      allReactions.sort((a, b) {
        Timestamp aTimestamp = a['timestamp'] as Timestamp;
        Timestamp bTimestamp = b['timestamp'] as Timestamp;

        return aTimestamp.compareTo(bTimestamp);
      });

      /*
    for (var ar in allReactions) {
      print('Completed Reply & Compare Part: ${ar['userId'].toString().substring(0, 5)}');
    }
    */

      setState(() {
        _isFetching = false;
        _comments = commentSnapshot.docs;
      });

      return allReactions;

    } catch (e) {
      print('Error in _fetchReactions: $e');

      return [];
    }
  }

  String _numberGenerator(List<DocumentSnapshot> allReactions, String reactorId) {
    List<String> userIdList = []; // List of user IDs

    for(var ar in allReactions)
      userIdList.add(ar['userId']);

    List<String> eliminatedUserIdList = userIdList.toSet().toList();
    //print('eliminatedUserIdList: $eliminatedUserIdList');

    List<String> withoutAuthor = eliminatedUserIdList;

    if(withoutAuthor.contains(widget.userId))
      withoutAuthor.remove(widget.userId);
    //print('withoutAuthor: $withoutAuthor');

    Map<String, String> numberMap = {};
    numberMap.addAll({widget.userId : '익명(글쓴이)'});
    withoutAuthor.forEach((reactor) {
      int number = withoutAuthor.indexOf(reactor) + 1;
      numberMap.addAll({reactor : '익명$number'});
    });
    //print('numberMap: $numberMap');

    return numberMap[reactorId]!;
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
              // To make Post section and Comments section to be scrollable altogether.
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _postSection(), // Post
                    _isFetching
                    ? Center(child: CircularProgressIndicator(color: conceptColor, backgroundColor: backgroundColor))
                    : _commentsSection(), // Comments
                    //: Container(width: 10, height: 10, color: Colors.pink,),
                  ],
                ),
              ),
            ),
            _addReactionSection(), // Add reaction (comment || reply)
          ],
        ),
      ),
    );
  }

  // From here is for appBar

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

  // From here is for _postSection

  Widget _postSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_currentTitle, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 14),
          Text(_currentContent, style: TextStyle(fontSize: 17)),
          SizedBox(height: 14),
          Row(
            children: [
              Text(DateFormat('MM/dd HH:mm').format(widget.timestamp), style: TextStyle(fontSize: 15, color: Colors.black54)),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                width: 0.5,
                height: 10,
                color: Colors.black54,
              ),
              Text('익명', style: TextStyle(fontSize: 15, color: Colors.black54, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ],
      ),
    );
  }

  // From here is for _commentsSection

  Widget _commentsSection() {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: _reactionsFuture,
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: conceptColor, backgroundColor: backgroundColor));
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData){
          return ListView.builder(
            physics: NeverScrollableScrollPhysics(), // Disable scrolling independently. It will be scrollable inside a SingleChildScrollView
            shrinkWrap: true, // Allow ListView to take only as much space as it needs.
            itemCount: _comments.length, // We define _comments in _fetchReactions
            itemBuilder: (context, index) {
              // 역순으로 보여주기. 즉, 최신 댓글이 제일 위에.
              var comment = _comments[index];

              var content = comment['content'];
              var timestamp = (comment['timestamp'] as Timestamp).toDate();
              var userId = comment['userId'];
              var anonymous = _numberGenerator(snapshot.data!, userId);
              var commentId = comment.id; // id of comment itself. not someone's id.

              return _commentCard(content, timestamp, anonymous, commentId);
            },
          );
        } else {
          return SizedBox(); // If this code operated, it means that this post does not has any reaction on it.
        }
      }
    );
  }

  Widget _commentCard(String content, DateTime timestamp, String anonymous, String commentId) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(border: Border(top: BorderSide(width: 0.5, color: Colors.grey))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(content, style: TextStyle(fontSize: 15, color: Colors.black)),
                    Row(
                      children: [
                        Text(DateFormat('MM/dd HH:mm').format(timestamp), style: TextStyle(fontSize: 15, color: Colors.black38)),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          width: 0.5,
                          height: 10,
                          color: Colors.black38,
                        ),
                        Text(anonymous, style: TextStyle(fontSize: 15, color: Colors.black38, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _replyToCommentId = commentId; // Set the current commentID to reply to
                  });
                },
                icon: Icon(Icons.reply_outlined, color: conceptColor),
              ),
            ],
          ),
          _repliesSection(commentId), // Show replies below the comment
        ],
      ),
    );
  }

  Widget _repliesSection(String commentId) {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: _reactionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: conceptColor, backgroundColor: backgroundColor));
        } else if (snapshot.hasError) {
          return Text('Error loading replies: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox(); // No replies to show
        } else if (snapshot.hasData) {
          var replies = snapshot.data!.where((doc) {
            return doc.reference.path.contains('comments/$commentId/replies'); // Filter replies for this comment (using parameter commentId and contains keyword).
          }).toList();
          return ListView.builder(
            physics: NeverScrollableScrollPhysics(), // Replies should not scroll independently. Will be scrolled as a whole with postSection.
            shrinkWrap: true,
            itemCount: replies.length, // replies: Replies for this commentId
            itemBuilder: (context, index) {
              var reply = replies[index];

              var content = reply['content'];
              var timestamp = (reply['timestamp'] as Timestamp).toDate();
              var userId = reply['userId'];
              var anonymous = _numberGenerator(snapshot.data!, userId);

              return _replyCard(content, timestamp, anonymous);
            },
          );
        } else {
          return SizedBox(); // If this code is operated, it means that this comment does not have any replies.
        }
      },
    );
  }

  Widget _replyCard(String content, DateTime timestamp, String anonymous) {
    return Container(
      margin: EdgeInsets.only(left: 20, top: 10), // Indent replies to the right
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
              Text(anonymous, style: TextStyle(fontSize: 14, color: Colors.black38, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _addReactionSection() {
    TextEditingController _inputController = TextEditingController();

    IconButton _suffixIconButton = IconButton(
      onPressed: () async {
        String content = _inputController.text.trim();

        // Get the current user.
        User? user = FirebaseAuth.instance.currentUser;

        if (content.isNotEmpty) {
          if (_replyToCommentId == null) {
            // Add a new comment via Firestore.
            await FirebaseFirestore.instance
                .collection('posts')
                .doc(widget.documentId)
                .collection('comments')
                .add({
              'content': content,
              'timestamp': Timestamp.now(),
              'userId': user?.uid,
            });
          } else {
            // Add a reply to a specific comment via Firestore
            await FirebaseFirestore.instance
                .collection('posts')
                .doc(widget.documentId)
                .collection('comments')
                .doc(_replyToCommentId)
                .collection('replies')
                .add({
              'content': content,
              'timestamp': Timestamp.now(),
              'userId': user?.uid,
            });

            // Reset _replyToCommentId after sending a reply
            setState(() {
              _replyToCommentId = null;
            });
          }

          // Clear the input field
          _inputController.clear();

          // Refetch comments to update the list and anonymous identifiers
          await _fetchReactions();
          _reactionsFuture = _fetchReactions();

          // Refresh the comments list
          setState(() {});
        }
      },
      icon: Icon(Icons.send, color: conceptColor),
    );

    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _inputController,
              autofocus: _replyToCommentId != null ? true : false,
              onTapOutside: (event) => {
                FocusManager.instance.primaryFocus?.unfocus(),
                // if unfocused -> change to 댓글을 입력하세요
                setState(() {
                  _replyToCommentId = null;
                }),
              },
              decoration: InputDecoration(
                hintText: _replyToCommentId == null ? '댓글을 입력하세요' : '대댓글을 입력하세요',
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