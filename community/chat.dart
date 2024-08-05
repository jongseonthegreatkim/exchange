import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../statics.dart';

class Chat extends StatefulWidget {
  const Chat({super.key, required this.isAuthor, required this.postAuthorId, required this.postId, required this.postTitle, required this.starterId});

  final bool isAuthor; // 글쓴이인지 아닌 지 판단하는 불 변수로, post에서는 무조건 false, my_chats에서는 true/false 다 가능하다.
  final String postAuthorId; // 글쓴이의 uid. 현재 접속자가 글쓴인지 아닌 지 판단해서 글쓴이의 채팅을 어느 쪽에 놓을 것인지 결정하기 위함.
  final String postId; // 채팅이 시작되게 된 postId. 모든 정보는 이 postId 문서 밑 chats 컬렉션에 저장되어있음.
  final String postTitle; // 채팅 제목을 이걸로 하면서, 채팅 별 차별화는 이걸로 끝.
  final String starterId; // 글쓴이가 아닌 상대방의 uid로, chats안에 이 uid로 시작하는 문서에 글쓴이와 해당 상대방의 모든 대화 정보가 저장되어있음.

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  // 초기화
  final ScrollController scrollController = ScrollController();
  final TextEditingController _chatInputController = TextEditingController();
  List<DocumentSnapshot> chatList = [];

  @override
  void initState() {
    super.initState();
    _fetchChatList(); /// 이름 바꿔야겠따 너.
  }

  Future<void> _fetchChatList() async {
    try {
      // 이 문서에서 채팅을 눌러서(widget.postId -> chats), 나와(widget.userId) 주고받은 채팅 목록(chatList)을 시간 순서대로(timestamp) 가져옴
      QuerySnapshot chatSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('chats')
          .doc(widget.starterId)
          .collection('chatList')
          .orderBy('timestamp', descending: true)
          .get();

      // 이를 chatList에 집어넣는다.
      setState(() {
        chatList = chatSnapshot.docs;
      });
    } catch (e) {
      print('Error fetching chat messages: $e');
    }
  }

  String _dateFormatter(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if(difference.inDays < 1) {
      return DateFormat('hh:mm').format(dateTime);
    } else {
      return DateFormat('MM/dd hh:mm').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        scrolledUnderElevation: 0,
        title: Text('${widget.postTitle}'),
        titleSpacing: 0,
        actions: [], /// 여기도 신고 기능 넣어도 될 듯
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ListView.separated(
                    shrinkWrap: true,
                    reverse: true,
                    controller: scrollController,
                    itemCount: chatList.length,
                    itemBuilder: (context, index) {
                      var chat = chatList[index];
                      String content = chat['content'];
                      bool isAuthor = chat['isAuthor'];
                      String timestamp = _dateFormatter(chat['timestamp'].toDate());

                      return ChatBubble(
                        chat: content,
                        isAuthor: isAuthor,
                        postAuthorId: widget.postAuthorId,
                        timestamp: timestamp,
                      );
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(height: 3);
                    },
                  ),
                ),
              ),
            ),
            _chatInputField(),
          ],
        )
      ),
    );
  }

  Widget _chatInputField() {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _chatInputController,
              onTapOutside: (event) => {
                FocusManager.instance.primaryFocus?.unfocus(),
              },
              decoration: InputDecoration(
                hintText: '메시지를 입력하세요',
                border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.keyColor)),
                contentPadding: EdgeInsets.only(left: 15),
                suffixIcon: IconButton(
                  icon: Icon(Icons.send, color: AppColors.keyColor),
                  onPressed: onFieldSubmitted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> onFieldSubmitted() async {
    addMessage();

    // 스크롤 위치 맨 밑으로 설정
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    _chatInputController.text = '';
  }

  void addMessage() async {
    String content = _chatInputController.text.trim();
    if (content.isEmpty) return;

    try {
      DocumentReference chatDocRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('chats')
          .doc(widget.starterId); // 스타터든, 글쓴이든, 무조건 starerId라는 이름의 문서가 있는 지 체크.

      DocumentSnapshot chatDocSnapshot = await chatDocRef.get();


      // 문서가 존재하지 않으면 더미 데이터를 추가하고 삭제합니다.
      if (!chatDocSnapshot.exists) {
        await chatDocRef.set({
          'dummy': true
        });

        await chatDocRef.update({
          'dummy': FieldValue.delete(),
        });
      }

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('chats')
          .doc(widget.starterId)
          .collection('chatList')
          .add({
        'timestamp': Timestamp.now(),
        'content': content,
        'isAuthor': widget.isAuthor,
      });

      _fetchChatList();
    } catch (e) {
      print('Error sending message: $e');
    }
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.chat, required this.isAuthor, required this.postAuthorId, required this.timestamp});

  final String chat;
  final bool isAuthor;
  final String postAuthorId;
  final String timestamp;

  @override
  Widget build(BuildContext context) {
    String? uid = FirebaseAuth.instance.currentUser?.uid; // 보는 사람의 uid

    late MainAxisAlignment _mainAxisAlignment;
    double leftMargin = 15;
    double rightMargin = 15;

    if(postAuthorId == uid) {
      if(isAuthor == true) {
        _mainAxisAlignment = MainAxisAlignment.end;
        leftMargin = 10;
      }
      if(isAuthor == false) {
        _mainAxisAlignment = MainAxisAlignment.start;
        rightMargin = 10;
      }
    }
    if(postAuthorId != uid) {
      if(isAuthor == true) {
        _mainAxisAlignment = MainAxisAlignment.start;
        rightMargin = 10;
      }
      if(isAuthor == false) {
        _mainAxisAlignment = MainAxisAlignment.end;
        leftMargin = 10;
      }
    }

    return Row(
      mainAxisAlignment: _mainAxisAlignment,
      children: [
        (_mainAxisAlignment != MainAxisAlignment.start)
        ? Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            timestamp,
            style: TextStyle(color: Colors.black, fontSize: 12),
          ),
        ) : SizedBox(),
        Container(
          margin: EdgeInsets.fromLTRB(leftMargin, 5, rightMargin, 5),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isAuthor ? AppColors.keyColor.withOpacity(0.2) : AppColors.keyColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            chat,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ),
        (_mainAxisAlignment == MainAxisAlignment.start)
        ? Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            timestamp,
            style: TextStyle(color: Colors.black, fontSize: 12),
          ),
        ) : SizedBox(),
      ],
    );
  }
}