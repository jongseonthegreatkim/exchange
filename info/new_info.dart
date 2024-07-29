import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For DateTime
import 'dart:async'; // For Timer

import 'full_relatives.dart';
import 'paper_to_submit.dart';
import '../colors.dart';

class NewInfo extends StatefulWidget {
  const NewInfo({super.key, required this.university});

  final String university;

  @override
  State<NewInfo> createState() => _NewInfoState();
}

class _NewInfoState extends State<NewInfo> {
  // Fetching basic data (universityData & '미준비서류')
  Future<void> _initialFetch() async {
    try {
      await _fetchUniversityData();
      await _paperCardBool();
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  // Fetch university data from Firestore
  Map<String, dynamic>? universityData;
  Future<void> _fetchUniversityData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('universities').doc(widget.university).get();
    setState(() {
      universityData = doc.data() as Map<String, dynamic>?;
    });
  }

  // For distinguish that user already has '미준비서류' field inside of uid document
  bool? _isFieldExist;
  List<dynamic> leftoverPapers = [];
  List<dynamic> donePapers = [];
  Future<void> _paperCardBool() async {
    // initialize leftoverPapers with whole '문서' in '서류'.
    leftoverPapers = universityData!['서류']['문서'];

    // Get the document snapshot
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    DocumentSnapshot uidSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    Map<String, dynamic> uidData = uidSnapshot.data() as Map<String, dynamic>;

    // put the existance of 미준비서류 field to _isFieldExist
    _isFieldExist = uidData.containsKey('미준비서류');

    if(_isFieldExist == true) {
      leftoverPapers = uidData['미준비서류'];
      donePapers = universityData!['서류']['문서'].where((element) => !leftoverPapers.contains(element)).toList();
    }
  }

  // To update leftover time every second.
  Timer? _timer;
  DateTime _now = DateTime.now();
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void initState() {
    print('new_info.dart initState');
    super.initState();
    _initialFetch();
    _startTimer();
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel(); // Cancel the time when the widget is disposed
  }

  @override
  Widget build(BuildContext context) {
    // _isFieldExist를 넣어서, _paperCardBool이 실행 중일 때는 UI를 그리지 못 하게 함.
    if(universityData == null || _isFieldExist == null) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.keyColor,
          backgroundColor: AppColors.backgroundColor,
        ),
      );
    } else {
      return SingleChildScrollView(
        child: Container(
          color: AppColors.backgroundColor,
          margin: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildScheduleSection(universityData!['일정']),
              _buildCriteriaSection(), // universityData!['기준']
              _buildPaperBanner(), // universityData!['서류']
              _buildRelativesSection(universityData!['상대교']),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildScheduleSection(Map<String, dynamic> schedule) {
    // Convert Firestore Timestamps to DateTime and keep keys
    List<MapEntry<String, DateTime>> dateEntries = schedule.entries.map((entry)
    => MapEntry(entry.key, (entry.value as Timestamp).toDate())).toList();

    // Remove past dates and sort the list by DateTime values
    dateEntries = dateEntries.where((entry) => entry.value.isAfter(DateTime.now())).toList();
    dateEntries.sort((a, b) => a.value.compareTo(b.value));

    if(dateEntries.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.university,
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700, color: Colors.black),
          ),
          SizedBox(height: 6),
          Text(
            '현재 ${widget.university}의 남은 일정이 없습니다!',
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
          SizedBox(height: 30),
        ],
      );
    }

    String latestKey = dateEntries[0].key.toString();
    // 가장 가까운 이벤트의 DateTime 정보. -> FlutterLocalNotification 활용해서, 1일 남았을 때 연락 가게 해줘야 함.
    DateTime latestValue = dateEntries[0].value;

    // Use _now that changes every second
    int dd = latestValue.difference(_now).inDays;
    int hh = latestValue.difference(_now).inHours - dd * 24;
    int mm = latestValue.difference(_now).inMinutes - (hh + dd * 24) * 60;
    int ss = latestValue.difference(_now).inSeconds - (mm + (hh + dd * 24) * 60) * 60;

    late String days;
    late String hours;
    late String minutes;
    late String seconds;
    // 숫자의 값이 0일 경우에 화면에 보이지 않게 하는 기술.
    days = dd!=0 ? '$dd일 ' : '';
    hours = hh!=0 ? '$hh시간 ' : '';
    minutes = mm!=0 ? '$mm분 ' : '';
    seconds = ss!=0 ? '$ss초' : '';

    late String displayingLeftoverTime;
    if(dd!=0) {
      displayingLeftoverTime = days;
    } else if(hh!=0) {
      displayingLeftoverTime = hours;
    } else if(mm!=0) {
      displayingLeftoverTime = minutes;
    } else {
      displayingLeftoverTime = seconds;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.university,
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700, color: Colors.black),
        ),
        SizedBox(height: 6),
        FittedBox(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$latestKey까지 ',
                  style: TextStyle(color: Colors.black, fontSize: 17),
                ),
                TextSpan(
                  text: displayingLeftoverTime,
                  style: TextStyle(color: Color(0xFFCC0000), fontSize: 17, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: "남았어요!",
                  style: TextStyle(color: Colors.black, fontSize: 17),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: [
              ...dateEntries.map((entry) {
                bool _isFirst = false;
                if(entry.key == latestKey)
                  _isFirst = true;
                return _buildScheduleCard(entry.key, DateFormat('yyyy년 MM월 dd일').format(entry.value), '캘린더에 추가', _isFirst);
              }),
            ],
          ),
        ),
        SizedBox(height: 30),
      ],
    );
  }
  Widget _buildScheduleCard(String title, String date, String calendar, bool _isFirst) {

    final Color _backgroundColor;
    _isFirst == true ? _backgroundColor = AppColors.keyBackgroundColor : _backgroundColor = AppColors.backgroundColor;

    return Container(
      margin: EdgeInsets.only(right: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _backgroundColor,
        border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 10),
          Text(
            date,
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('기능 준비 중입니다!')));
            },
            child: Text(calendar, style: TextStyle(color: Colors.black, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _buildCriteriaSection() {
    Map<String, dynamic>? criteria = universityData!['기준'];

    // 선발 기준, 제출 가능 어학성적 및 커트라인, 지원 조건 등
    List<String> standards = (criteria != null) ? criteria.keys.toList() : [];

    if(criteria == null)
      return Container(); // criteria가 없는 경우 -> 그냥 CriteriaSection을 없앤다.

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ...standards.map((standard) {
              List<dynamic> standardContents = criteria[standard].values.toList();

              //return Container(child: Text('123'));
              return _buildCriteriaButton(standard, standardContents);
            }),
          ],
        ),
        SizedBox(height: 30),
      ],
    );
  }
  Widget _buildCriteriaButton(String standard, List<dynamic> standardContents) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1),
        color: AppColors.backgroundColor,
      ),
      child: Center(
        child: Text(
          standard,
          style: TextStyle(
            color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPaperBanner() {
    Map<String, dynamic>? paper = universityData!['서류'];

    // 아직 '서류' 필드가 준비되지 않은 대학교의 경우
    if(paper == null)
      return SizedBox();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaperToSubmit(
              university: widget.university,
              leftoverPapers: leftoverPapers,
              donePapers: donePapers,
              warnings: paper['주의사항'],
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 30),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: Color(0xFFD1E0EC),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            (_isFieldExist == true)
            ? Icon(Icons.warning, color: Color(0xFFDA3B3B), size: 30)
            : Icon(Icons.subject, color: Color(0xFF000000), size: 30),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (_isFieldExist == true) ? '아직 준비 하지 못한 서류 ${leftoverPapers.length}가지' : '${widget.university} 제출 서류',
                  style: TextStyle(
                    color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  (_isFieldExist == true) ? '다시 확인하기' : '1분 만에 확인하기',
                  style: TextStyle(
                    color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelativesSection(Map<String, dynamic>? relatives) {
    List<String> areas = (relatives != null) ? relatives.keys.toList() : [];

    if(relatives != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '지원가능 대학 목록',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: Colors.black),
              ),
              GestureDetector(
                onTap: () {
                  // 지원 가능 대학 목록 전체 보기
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FullRelatives(
                    relatives: relatives,
                    areas: areas,
                  )));
                },
                child: Row(
                  children: [
                    Text("전체 보기", style: TextStyle(fontSize: 15, color: Colors.black)),
                    Icon(Icons.keyboard_arrow_right_sharp, size: 20, color: Colors.black),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          FittedBox(
            child: Text(
              '권역 별로 지원이 가능한 대학교 목록을 확인해보세요!',
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 222,
            child: ListView(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              children: [
                ...areas.map((area) {
                  List universitiesInArea = relatives[area].keys.toList();

                  // previewSplit개 만큼만 universitiesInArea에서 떼 올 예정
                  int previewSplit = (universitiesInArea.length >= 5) ? 5 : universitiesInArea.length;

                  // 떼 온 값을 previewUnivList에 넣는다
                  List previewUnivList = universitiesInArea.sublist(0, previewSplit);

                  return _buildRelativesCard(area, previewUnivList, relatives);
                }),
              ],
            ),
          ),
          SizedBox(height: 30),
        ],
      );
    } else {
      return Container(); // relatives가 없는 경우 -> 그냥 RelativesSection을 없앤다.
    }
  }
  Widget _buildRelativesCard(String title, List<dynamic> universities, Map<String, dynamic> relatives) {
    // relatives와 areas : 자세히 보기를 위해서 사용
    List<String> areas = relatives.keys.toList();

    return Container(
      width: 200,
      margin: EdgeInsets.only(right: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: title,
                  style: TextStyle(color: Color(0xFFCC0000), fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: ' 대학',
                  style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          ...universities.map((university) =>
              Column(
                children: [
                  Text(university, style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    overflow: TextOverflow.ellipsis,
                  )),
                  SizedBox(height: 5),
                ],
              ),
          ),
          SizedBox(height: 15),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FullRelatives(
                relatives: relatives,
                areas: areas,
              )));
            },
            child: Text("전체 보기", style: TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _buildCriteriaCard(String university, String standard, List<dynamic> standdardContents, String etc) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1),
        color: AppColors.backgroundColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: university,
              style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: standard,
                  style: TextStyle(color: Color(0xFFCC0000), fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          ...standdardContents.map((standardContent) =>
              Column(
                children: [
                  Text(standardContent, style: TextStyle(fontSize: 15)),
                  SizedBox(height: 5),
                ],
              ),
          ),
          if(etc != "빈칸")...[
            SizedBox(height: 15),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('기능 준비 중입니다!')));
              },
              child: Text(
                etc,
                style: TextStyle(fontSize: 15),
              ),
            ),
          ]
        ],
      ),
    );
  }
}