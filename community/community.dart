import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'new_post.dart';
import 'post.dart';
import '../statics.dart';

class Community extends StatefulWidget {
  // 강제가 아닌 경우에는 required 안 넣는 구나.
  const Community({super.key, required this.username, required this.university, required this.searchField});

  final String username;
  final String university;
  final String searchField; // TextFormField의 text

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  final int _postLimit = 10; // Number of posts to fetch per batch // 추후에 이 값은 50으로 올리기
  final List<DocumentSnapshot> _posts = []; // To store fetched posts
  bool _isFetching = true; // To indicate if posts are being fetched
  bool _hasMorePosts = true; // To indicate if there are more posts to fetch
  DocumentSnapshot? _lastDocument; // To track the last fetched document

  Map<String, int> likesCountCache = {};
  Map<String, int> reactionsCountCache = {};

  @override
  void initState() {
    super.initState();
    _fetchInitialPosts(); // Fetch posts when the screen initializes.
  }

  // ensure update the UI whenever 'widget.searchField' has been changed.
  @override
  void didUpdateWidget(Community oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.searchField != widget.searchField)
      _refreshPosts();
  }

  // 종국적으로 _fetchInitialPosts와 _fetchMorePosts의 통합을 추진해야 한다
  Future<void> _fetchInitialPosts() async {

    print('_fIP Started');

    setState(() {
      _isFetching = true;
    });

    try{
      // Fetch posts from Firestore ordered by timestamp
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .limit(_postLimit)
          .get(); // Limit to _postLimit posts

      List<DocumentSnapshot> filteredDocs = querySnapshot.docs.where((doc) {
        String title = doc['title'];
        String content = doc['content'];
        if(widget.searchField.isNotEmpty) {
          return title.contains(widget.searchField) || content.contains(widget.searchField);
        } else {
          return true;
        }
      }).toList();

      // Store the fetched posts in a state variable
      if(filteredDocs.isNotEmpty) {
        if(mounted) { // check if the widget is still mounted
          await _fetchAdditionalData(filteredDocs);

          setState(() {
            _posts.addAll(filteredDocs); // Add all fetched documents to _posts
            _lastDocument = filteredDocs.last;
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

      List<DocumentSnapshot> filteredDocs = querySnapshot.docs.where((doc) {
        String title = doc['title'];
        String content = doc['content'];
        if(widget.searchField.isNotEmpty) {
          return title.contains(widget.searchField) || content.contains(widget.searchField);
        } else {
          return true;
        }
      }).toList();

      if(filteredDocs.isNotEmpty) {
        if(mounted) { // check if the widget is still mounted
          setState(() {
            _posts.addAll(filteredDocs);
            _lastDocument = filteredDocs.last;
            _isFetching = false;
          });

          await _fetchAdditionalData(filteredDocs);
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
      // _fetchAdditionalData에서 이 두 값의 key에 postId가 없는 경우에만 (좋아요 수, 댓글 수)를 value로 추가하기 때문에,
      // 이 두 값을 리셋해줘야 함.
      likesCountCache = {};
      reactionsCountCache = {};
    });
    await _fetchInitialPosts();
  }

  // called in _fetchInitialPosts and _fetchMorePosts
  Future<void> _fetchAdditionalData(List<DocumentSnapshot> posts) async {
    /*
    for (var post in posts) {
      String postId = post.id;
      if (!likesCountCache.containsKey(postId)) {
        likesCountCache[postId] = await _fetchLikesCount(postId);
      }
      if (!reactionsCountCache.containsKey(postId)) {
        reactionsCountCache[postId] = await _fetchReactionsCount(postId);
      }
    }
    */

    // Down here is much faster version of fetching additional data than upper one.
    // I need to know why

    print('_fAD Started');

    List<Future<int>> likesFutures = [];
    List<Future<int>> reactionsFutures = [];
    List<String> postIds = posts.map((post) => post.id).toList();
    print('postIds: $postIds');

    for (var postId in postIds) {
      if (!likesCountCache.containsKey(postId)) {
        likesFutures.add(_fetchLikesCount(postId));
      }
      if (!reactionsCountCache.containsKey(postId)) {
        reactionsFutures.add(_fetchReactionsCount(postId));
      }
    }

    List<int> likesCounts = await Future.wait(likesFutures);
    List<int> reactionsCounts = await Future.wait(reactionsFutures);

    for (int i = 0; i < postIds.length; i++) {
      likesCountCache[postIds[i]] = likesCounts[i];
      reactionsCountCache[postIds[i]] = reactionsCounts[i];
    }

    setState(() {});
  }

  // called in _fetchAdditionalData
  Future<int> _fetchLikesCount(String postId) async {
    QuerySnapshot likesSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .get();

    return likesSnapshot.size;
  }
  Future<int> _fetchReactionsCount(String postId) async {
    QuerySnapshot commentSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .get();

    int commentCount = commentSnapshot.size;

    int replyCount = 0;
    for(var comment in commentSnapshot.docs) {
      QuerySnapshot replySnapshot = await comment.reference.collection('replies').get();
      replyCount += replySnapshot.size;
    }

    return commentCount + replyCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: _isFetching && _posts.isEmpty
      ? Center(child: CircularProgressIndicator(color: AppColors.keyColor, backgroundColor: AppColors.white))
      : RefreshIndicator(
        onRefresh: _refreshPosts,
        color: AppColors.keyColor, // 리프레시 하면 상단에 뜨는 CircularProgressIndicator의 색상.
        backgroundColor: AppColors.white,
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
              var title = post['title']; // 제목
              var content = post['content']; // 내용
              var timestamp = (post['timestamp'] as Timestamp).toDate(); // 작성 시간
              var userId = post['userId']; // 작성자 UID
              var postId = post.id; // 문서 ID

              int likesCount = likesCountCache[postId] ?? 0;
              int reactionsCount = reactionsCountCache[postId] ?? 0;

              return _buildPostCard(title, content, timestamp, userId, postId, likesCount, reactionsCount);
            },
          ),
        ),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          // Navigate to the post submission screen
          Navigator.push(context, MaterialPageRoute(builder: (context) => PostSubmissionScreen(onPostCreated: _refreshPosts)));
        },
        child: const Text('글 쓰기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        style: ButtonStyle(
          padding: WidgetStateProperty.resolveWith((states) {
            return const EdgeInsets.symmetric(horizontal: 30);
          }),
          // foregroundColor = TextStyle(color), overlayColor = color when overlayed
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            return Colors.black.withOpacity(0.8);
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            return AppColors.secondBackgroundColor;
          }),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            return Colors.grey.withOpacity(0.1);
          }),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
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

  /// _buildPostCard를 그리는 원초적인 방법에 대해서 다시 생각해보자.
  /// 이 방법은 좋다. 이 방법을 그대로 개인정보 쪽에 대입할 수 없는가?

  // userId 받아오긴 하지만 사용하진 않는다. 사용자가 원하면 공개하게 할 수도 있으니, 일단 받아오도록 하자.
  Widget _buildPostCard(String title, String content, DateTime timestamp, String userId, String documentId, int likesCount, int reactionsCount) {
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
            username: widget.username, // For blocking feature.
            university: widget.university, // For blocking feature.
          ),
        ));
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 15, 10, 0),
        padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
        decoration: const BoxDecoration(border: Border(top: BorderSide(width: 0.5, color: Colors.grey))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 & 내용
            Text(
              title,
              style: AppTextStyle.subtitleTextStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),
            Text(
              content,
              style: AppTextStyle.mediumTextStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),
            // 익명 & 시간
            Row(
              children: [
                Text(
                  _formatTimestamp(timestamp),
                  style: AppTextStyle.contentTextStyle,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: 0.5,
                  height: 10,
                  color: Color(0xFF9A9A9A),
                ),
                Text(
                  '익명',
                  style: AppTextStyle.contentTextStyle,
                ),
              ],
            ),
            const SizedBox(height: 5),
            // 좋아요 & 댓글
            Row(
              children: [
                Icon(Icons.thumb_up, size: 14, color: Color(0xFFF92015).withOpacity(0.5)),
                const SizedBox(width: 5),
                Text('$likesCount', style: TextStyle(fontSize: 14, color: Color(0xFFF92015).withOpacity(0.5))),
                const SizedBox(width: 10),
                Icon(Icons.comment, size: 14, color: Color(0xFF07BCBC).withOpacity(0.5)),
                const SizedBox(width: 5),
                Text('$reactionsCount', style: TextStyle(fontSize: 14, color: Color(0xFF07BCBC).withOpacity(0.5))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
// modified