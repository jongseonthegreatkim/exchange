import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'new_post.dart';
import 'post.dart';

Color backgroundColor = Color(0xFFF8F7F4);
Color conceptColor = Color(0xFF73A9DA);
Color conceptBackgroundColor = Color(0xFFF5DADA);
Color intermediateBackgroundColor = Color(0xFFfbfff8);

class Community extends StatefulWidget {
  const Community({super.key});

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {

  final int _postLimit = 10; // Number of posts to fetch per batch // 추후에 이 값은 50으로 올리기
  final List<DocumentSnapshot> _posts = []; // To store fetched posts
  bool _isFetching = true; // To indicate if posts are being fetched
  bool _hasMorePosts = true; // To indicate if there are more posts to fetch
  DocumentSnapshot? _lastDocument; // To track the last fetched document

  @override
  void initState() {
    super.initState();
    _fetchInitialPosts(); // Fetch posts when the screen initializes.
  }

  // 종국적으로 _fetchInitialPosts와 _fetchMorePosts의 통합을 추진해야 한다
  Future<void> _fetchInitialPosts() async {
    setState(() {
      _isFetching = true;
    });

    try{
      // Fetch posts from Firestore ordered by timestamp
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .limit(_postLimit) // Limit to _postLimit posts
          .get();

      // Store the fetched posts in a state variable
      if(querySnapshot.docs.isNotEmpty) {
        if(mounted) { // check if the widget is still mounted
          setState(() {
            _posts.addAll(querySnapshot.docs); // Add all fetched documents to _posts
            _lastDocument = querySnapshot.docs.last;
            _isFetching = false; // Set fetching to false once data is loaded
          });
        }
      } else {
        if(mounted) { // check if the widget is still mounted
          setState(() {
            _hasMorePosts = false;
            _isFetching = false;
          });
        }
      }

    } catch (e) {
      print('Error fetching posts: $e');
      if(mounted) { // check if the widget is still mounted
        setState(() {
          _isFetching = false;
        });
      }
    };
  }

  Future<void> _fetchMorePosts() async {
    if(!_hasMorePosts || _isFetching) return;

    setState(() {
      _isFetching = true;
    });

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(_postLimit)
          .get();

      if(querySnapshot.docs.isNotEmpty) {
        if(mounted) { // check if the widget is still mounted
          setState(() {
            _posts.addAll(querySnapshot.docs);
            _lastDocument = querySnapshot.docs.last;
            _isFetching = false;
          });
        }
      } else {
        if(mounted) { // check if the widget is still mounted
          setState(() {
            _hasMorePosts = false;
            _isFetching = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching more posts: $e');
      if(mounted) { // check if the widget is still mounted\
        setState(() {
          _isFetching = false;
        });
      }
    }
  }

  Future<void> _refreshPosts() async {
  // This function is sent to new_post.dart / post.dart and used with a name of onPostCreated() / onPostFixed()
  // Because this fuction is called when post is created / Fixed.
    setState(() {
      _posts.clear();
      _lastDocument = null;
      _hasMorePosts = true;
    });
    await _fetchInitialPosts();
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if(difference.inMinutes < 1) {
      return "방금 전";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}분 전";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}시간 전";
    } else {
      return "${difference.inDays}일 전";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: _isFetching && _posts.isEmpty
      ? Center(child: CircularProgressIndicator(
        color: conceptColor,
        backgroundColor: backgroundColor,
      ))
      : RefreshIndicator(
        onRefresh: _refreshPosts,
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            final maxScroll = scrollNotification.metrics.maxScrollExtent;
            final currentScroll = scrollNotification.metrics.pixels;
            final delta = 200.0; // Adjust this value as need to trigger fetching earlier

            if (scrollNotification is ScrollEndNotification && (currentScroll > (maxScroll - delta)) && !_isFetching)
              _fetchMorePosts();
            return false;
          },
          child: ListView.builder(
            itemCount: _posts.length,
            itemBuilder: (context, index) {
              var post = _posts[index];
              var title = post['title'] ?? 'No title';
              var content = post['content'] ?? 'No Content';
              var timestamp = (post['timestamp'] as Timestamp).toDate();
              var userId = post['userId'] ?? 'Anonymous';
              var documentId = post.id;

              return _buildPostCard(title, content, timestamp, userId, documentId);
            },
          ),
        ),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          // Navigate to the post submission screen
          Navigator.push(context, MaterialPageRoute(builder: (context) => PostSubmissionScreen(onPostCreated: _refreshPosts)));
        },
        child: Text('글 쓰기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        style: ButtonStyle(
          padding: WidgetStateProperty.resolveWith((states) {
            return EdgeInsets.symmetric(horizontal: 30);
          }),
          // foregroundColor = TextStyle(color), overlayColor = color when overlayed
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            return Colors.black.withOpacity(0.8);
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            return conceptColor;
          }),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            return Colors.grey.withOpacity(0.1);
          }),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// _buildPostCard를 그리는 원초적인 방법에 대해서 다시 생각해보자.
  /// 이 방법은 좋다. 이 방법을 그대로 개인정보 쪽에 대입할 수 없는가?

  // userId 받아오긴 하지만 사용하진 않는다. 사용자가 원하면 공개하게 할 수도 있으니, 일단 받아오도록 하자.
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
            onPostFixed: _refreshPosts,
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
            Row(
              children: [
                Text(_formatTimestamp(timestamp), style: TextStyle(fontSize: 14, color: Colors.black38)),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  width: 0.5,
                  height: 10,
                  color: Colors.black38,
                ),
                Text('익명', style: TextStyle(fontSize: 14, color: Colors.black38, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
