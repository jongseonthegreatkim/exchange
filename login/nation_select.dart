import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../main.dart';
import '../statics.dart';

class NationSelect extends StatefulWidget {
  const NationSelect({super.key, required this.username, required this.university, this.selectedNations, required this.from});

  final String username;
  final String university;
  final List<String>? selectedNations;
  final String from;

  @override
  State<NationSelect> createState() => _NationSelectState();
}

class _NationSelectState extends State<NationSelect> {
  // 선택한 권역은 다른 디자인으로 보여주기 위한 boolean 값 리스트. 일단 false로 다 채움.
  List<bool> _isCheckedList = [];

  // 국기 주소 & 국가명 저장해놓을 리스트
  List<String> _imageAddressList = [];
  List<String> _nationTextList = [];

  // 국기 주소 & 국가명 데이터를 Firestore에서 받아와서 위 두 리스트에 저장
  Future<void> fetchImageAndNationAndBool() async {

    print('fetchIANAB start');

    try {
      // Firestore의 collection에 접근
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('nations')
          .orderBy('ratio', descending: false) // 교환 많이가는 순서대로 정렬
          .get();

      // 하나하나의 document마다 imageAddress와 nationText를 가져와 _imagesAddressList, _nationsTextList에 집어넣는다
      for(var doc in querySnapshot.docs) {
        Map<String, dynamic> image = doc.data() as Map<String, dynamic>;
        String imageAddress = image['image'];
        String nationText = doc.id;
        _imageAddressList.add(imageAddress);
        _nationTextList.add(nationText);

        print('fetching _imageAddress and _nationText');
        print('_imageAddressList: $_imageAddressList');
        print('_nationTextList: $_nationTextList');

      }

      print('_imageAddressList: $_imageAddressList');
      print('_nationTextList: $_nationTextList');

      // 선택한 국가는 다른 디자인으로 보여주기 위한 boolean 값 리스트.
      if(widget.selectedNations == null) {
        // selectedNations를 넘겨주지 않았다면, 즉, (get_info 혹은 profile의 '희망국가 선택하기')에서 접근했다면, 모두 false로 채운다
        _isCheckedList = List<bool>.filled(querySnapshot.docs.length, false);
      } else {
        // selectedNations를 넘겨줬다면, 'profile'의 '희망국가 변경하기'에서 접근한 경우
        _isCheckedList = List<bool>.filled(querySnapshot.docs.length, false);
        for(int index=0; index<_nationTextList.length; index++) {
          if(widget.selectedNations!.contains(_nationTextList[index])) {
            _isCheckedList[index] = true;
          }
        }
      }

      print('_isCheckedList: $_isCheckedList');

      // 그림 다시 그리기 -> 이래야 _isCheckedList에 true가 존재함을 인식해서 bottomSheet의 색상을 바꿔줄 수 있음.
      setState(() {

      });
    } catch (e) {
      print('fetching image and nation and bool faced Error: $e');
    }
  }

  // fetchImageAndNationAndBool에 대응하는 late future.
  late Future<void> fetchFuture;

  Future<void> saveNationsAndNavigate(List<bool> _isCheckedList, List<String> _nationTextList, bool _isSkip) async {
    // 현재 사용자의 uid를 받아옴
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    // selectedNations 처리
    if(uid != null) {
      // 선택된 국가들이 들어갈 리스트
      List<String> selectedNations = [];

      // 건너뛰기가 아닌 경우
      // 선택된 국가들 (corresponding _isCheckedList[i]가 true인)을 selectedNations에 집어넣는다.
      if(_isSkip == false) {
        for(int i=0; i<_isCheckedList.length; i++) {
          if(_isCheckedList[i])
            selectedNations.add(_nationTextList[i]);
        }
      }

      // 해당 uid 문서에 접근한 뒤, {nations : selectedNations} 추가한다.
      CollectionReference users = FirebaseFirestore.instance.collection('users');
      await users.doc(uid).update({
        'nations' : selectedNations,
      });

    } else {
      print('Problem! UID does not exist');
    }

    // (info 혹은 profile)로 이동하는 코드.
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
        Home(
          username: widget.username,
          university: widget.university,
          bottomIndex: (widget.from == 'get_info') ? 0 : 2,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchFuture = fetchImageAndNationAndBool();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _appBar(context),
      body: _body(context),
      bottomSheet: _bottomSheet(context),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      scrolledUnderElevation: 0, // Disable light background color when we scroll body upward.
      actions: (widget.from == 'get_info') ? [
        GestureDetector(
          onTap: () async {
            // uid 문서의 nations 필드를 생성 + 홈으로 이동하는 코드.
            // 이 경우엔 nations 필드의 값이 []
            await saveNationsAndNavigate(_isCheckedList, _nationTextList, true);
          },
          child: Container(
            margin: const EdgeInsets.only(right: 15),
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Text(
              '건너뛰기',
              style: TextStyle(
                color: Colors.black, fontSize: 17, fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ] : [],
    );
  }

  Widget _body(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
      color: AppColors.white,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Text(
              '어느 국가로 교환학생을 가고 싶나요?',
              style: TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '여러 국가를 골라도 상관 없어요',
              style: TextStyle(
                color: Colors.black45, fontSize: 15, fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '고르고 싶지 않으시면 우측 상단 건너뛰기를 눌러주세요',
              style: TextStyle(
                color: Colors.black45, fontSize: 15, fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            FutureBuilder(
              future: fetchFuture,
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: AppLoading.CPI,
                  );
                } else {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: _nationTextList.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1/1,
                    ),
                    itemBuilder: (context, index) {
                      Color _backgroundColor = (_isCheckedList[index] == false) ? AppColors.white : AppColors.backgroundColor;
                      Color _borderColor = (_isCheckedList[index] == false) ? Colors.grey.withOpacity(0.25)  : AppColors.keyColor;

                      String _imageAddress = _imageAddressList[index];
                      String _nationText = _nationTextList[index];
                      Color _textColor = (_isCheckedList[index] == false) ? Colors.black54 : Colors.black;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _isCheckedList[index] = !_isCheckedList[index];
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.fromLTRB(11, 5, 11, 0),
                          decoration: BoxDecoration(
                            color: _backgroundColor,
                            borderRadius: BorderRadius.circular(1000),
                            border: Border.all(color: _borderColor, width: 2),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(_imageAddress.toString(), width: 40, height: 25),
                              const SizedBox(height: 3),
                              FittedBox(
                                child: Text(
                                  _nationText,
                                  style: TextStyle(
                                    color: _textColor, fontSize: 20, fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              }
            ),
            // _bottmSheet 높이의 SizedBox를 만들어서, 가리는 부분이 없게 함.
            const SizedBox(height: 130),
          ],
        ),
      ),
    );
  }

  Widget _bottomSheet(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 130,
      color: AppColors.white,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: double.infinity,
          height: 50,
          margin: EdgeInsets.fromLTRB(30, 15, 30, 0),
          decoration: BoxDecoration(
            color: (_isCheckedList.contains(true)) ? AppColors.backgroundColor : Colors.grey.withOpacity(0.1),
            border: Border.all(
              color: (_isCheckedList.contains(true)) ? AppColors.keyColor : AppColors.keyColor.withOpacity(0.5),
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(100),
          ),
          child: GestureDetector(
            onTap: () async {
              print(_isCheckedList);
              // 하나라도 선택했을 때만 넘어갈 수 있게 하기
              if(_isCheckedList.contains(true)) {
                // uid 문서의 nations 필드를 생성 + (홈 or Profile.dart) 으로 이동하는 코드.
                // 이 경우엔 nations 필드의 값이 []가 아니고 존재
                await saveNationsAndNavigate(_isCheckedList, _nationTextList, false);
              }
            },
            child: Center(
              child: Text(
                '체크 완료',
                style: TextStyle(
                  color: (_isCheckedList.contains(true)) ? Colors.black : Colors.grey,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}