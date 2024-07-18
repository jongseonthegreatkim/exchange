import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../colors.dart';
import '../community/chat.dart';

class MyChats extends StatefulWidget {
  const MyChats({super.key, required this.userId});

  final String userId;

  @override
  State<MyChats> createState() => _MyChatsState();
}

class _MyChatsState extends State<MyChats> {
  List<Map<String, dynamic>> chatList = [];
  late Future<void> _fetchChatFuture;

  @override
  void initState() {
    super.initState();
    _fetchChatFuture = _fetchChatList(); // 쌍으로 묶어줌
  }

  Future<void> _fetchChatList() async {
    try {
      // Fetch chats where the current user is either the author or the recipient
      QuerySnapshot postsSnapshot = await FirebaseFirestore.instance.collection('posts').get();

      List<Map<String, dynamic>> chats = [];

      for (var post in postsSnapshot.docs) {
        String postId = post.id;
        String postAuthorId = post['userId'];
        String postTitle = post['title'];

        // Fetch the last chat message initiated by the current user
        QuerySnapshot lastChatSnapshot = await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .collection('chats')
            .doc(widget.userId)
            .collection('chatList')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        if (lastChatSnapshot.docs.isNotEmpty) {
          var lastChat = lastChatSnapshot.docs.first;

          chats.add({
            'postAuthorId' : postAuthorId, // 이 유저 id 아님
            'postId' : postId,
            'postTitle' : postTitle,
            'starterId': widget.userId, // 이 유저 id임
            'lastMessage': lastChat['content'],
            'timestamp': lastChat['timestamp'],
          });
        }

        // Fetch the last chat message initiated by others to the current user
        // Only inspect post that is written by this user.
        if(postAuthorId == widget.userId) {

          print('${widget.userId} has a post with id of $postId');

          QuerySnapshot chatSnapshot = await FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
              .collection('chats')
              .get();

          for (var chat in chatSnapshot.docs) {
            QuerySnapshot lastChatSnapshot = await FirebaseFirestore.instance
                .collection('posts')
                .doc(postId)
                .collection('chats')
                .doc(chat.id)
                .collection('chatList')
                .orderBy('timestamp', descending: true)
                .limit(1)
                .get();

            if (lastChatSnapshot.docs.isNotEmpty) {
              var lastChat = lastChatSnapshot.docs.first;
              chats.add({
                'postAuthorId' : widget.userId, // 이 유저 id임
                'postId' : postId,
                'postTitle' : postTitle,
                'starterId': chat.id, // 이 유저 id 아님
                'lastMessage': lastChat['content'],
                'timestamp': lastChat['timestamp'],
              });
            }
          }
        }
      }

      setState(() {
        chatList = chats;
      });
    } catch (e) {
      print('Error fetching chat list: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        scrolledUnderElevation: 0,
        title: const Text('채팅'),
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: FutureBuilder<void>(
          future: _fetchChatFuture,
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: AppColors.keyColor, backgroundColor: AppColors.backgroundColor));
            } else if(snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return ListView.builder(
                itemCount: chatList.length,
                itemBuilder: (context, index) {
                  return _chatPreview(chatList[index]);
                },
              );
            }
          },
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return "방금";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}분 전";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}시간 전";
    } else {
      return "${difference.inDays}일 전";
    }
  }

  Widget _chatPreview(var chat) {
    var lastMessage = chat['lastMessage'];
    var timestamp = (chat['timestamp'] as Timestamp).toDate();
    var formattedTime = _formatTimestamp(timestamp);
    String title = chat['postTitle'];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Chat(
              isAuthor: chat['postAuthorId'] == widget.userId ? true : false,
              postAuthorId: chat['postAuthorId'],
              postId: chat['postId'],
              postTitle: chat['postTitle'],
              starterId: chat['starterId'],
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.all(15),
        decoration: BoxDecoration(

        ),
        child: Row(
          children: [
            Icon(Icons.person, color: AppColors.keyColor, size: 40),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.black, fontSize: 19, fontWeight: FontWeight.w600
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    lastMessage,
                    style: TextStyle(
                        color: Colors.black54, fontSize: 17,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(formattedTime),
          ],
        ),
      ),
    );
  }
}
