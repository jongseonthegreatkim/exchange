import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For DateTime
import 'dart:async'; // For Timer
import 'full_relatives.dart';

Color backgroundColor = Color(0xFFF8F7F4);
Color conceptColor = Color(0xFF73A9DA);
Color conceptBackgroundColor = Color(0xFFF5DADA);
Color intermediateBackgroundColor = Color(0xFFfbfff8);

class Info extends StatefulWidget {
  const Info({super.key, required this.university});

  final String university;

  @override
  State<Info> createState() => _InfoState();
}

class _InfoState extends State<Info> {
  // _timer variable to update leftover time every second.
  Timer? _timer;
  DateTime _now = DateTime.now();

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  Map<String, dynamic>? universityData;

  Future<void> _fetchUniversityData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('universities').doc(widget.university).get();
      setState(() {
        universityData = doc.data() as Map<String, dynamic>?;
      });
    } catch (e) {
      print('Error fetching university data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
    _fetchUniversityData();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the time when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(universityData == null) {
      return Center(child: CircularProgressIndicator(color: conceptColor, backgroundColor: backgroundColor));
    } else {
      return SingleChildScrollView(
        child: Container(
          color: backgroundColor,
          margin: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildScheduleSection(universityData!['일정']), // 모집 일정 안내
              SizedBox(height: 30),
              _buildRelativesSection(universityData!['상대교']), // 지원 가능 대학 목록
              SizedBox(height: 30),
              _buildCriteriaSection(universityData!['기준']), // 지원 조건 및 선발 기준
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          child: Text(
            '${widget.university} $latestKey까지',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$days$hours$minutes$seconds',
                style: TextStyle(color: Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: " 남았어요!",
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        SizedBox(
          height: 115,
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
      ],
    );
  }
  Widget _buildScheduleCard(String title, String date, String calendar, bool _isFirst) {

    final Color _backgroundColor;
    _isFirst == true ? _backgroundColor = conceptColor.withOpacity(0.3) : _backgroundColor = backgroundColor;

    return Container(
      margin: EdgeInsets.only(right: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.5), width: 0.35),
        color: _backgroundColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.black, fontSize: 17),
          ),
          SizedBox(height: 10),
          Text(
            date,
            style: TextStyle(color: Colors.black, fontSize: 17),
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('기능 준비 중입니다!')));
            },
            child: Text(calendar, style: TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _buildRelativesSection(Map<String, dynamic>? relatives) {
    List<String> areas = (relatives != null) ? relatives.keys.toList() : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '지원 가능 대학들을 확인해보세요!',
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
            GestureDetector(
              onTap: () {
                // 지원 가능 대학 목록 전체 보기
                Navigator.push(context, MaterialPageRoute(builder: (context) => FullRelatives(
                  relatives: (relatives != null) ? relatives : {},
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
        SizedBox(height: 10),
        SizedBox(
          height: 221,
          child: (relatives != null)
          ? ListView(
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
          )
          : Container(
            color: intermediateBackgroundColor,
            child: Center(
              child: Text('아직 ${widget.university}의 지원 가능 대학 섹션은 지원되고 있지 않습니다.'),
            ),
          ),
        ),
      ],
    );
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
        border: Border.all(color: Colors.grey.withOpacity(0.5), width: 0.35),
        color: intermediateBackgroundColor
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.black, fontSize: 17),
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
            child: Text("자세히 보기", style: TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _buildCriteriaSection(Map<String, dynamic>? criteria) {

    // 선발 기준, 제출 가능 어학성적 및 커트라인, 지원 조건
    List<String> standards = (criteria != null) ? criteria.keys.toList() : [];

    /// 이거 실효성 있는 지 체크해야 함.
    List<String> desiredOrder = ['지원 조건', '선발 기준', '제출 가능 어학성적 및 커트라인'];

    // desiredOrder에 맞게 standards를 재배열
    standards.sort((a, b) {
      int indexA = desiredOrder.indexOf(a);
      int indexB = desiredOrder.indexOf(b);
      return indexA.compareTo(indexB);
    });


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "지원 조건과 선발 기준을 알아봐요!",
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        SizedBox(height: 10),
        (criteria != null)
        ? ListView(
          scrollDirection: Axis.vertical,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            ...standards.map((standard) {
              List standardContents = criteria[standard].values.toList(); // 조건 목록들

              // resort criteria['standard'] based on order of criteria['standard'].key
              List<MapEntry<String, dynamic>> sortedEntries = criteria[standard].entries.toList()..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));
              // Re-put sorted value into standardContents
              standardContents = sortedEntries.map((entry) => entry.value).toList();

              String etc = '내 성적 입력하기';
              (standard == '선발 기준') ? (etc = '빈칸') : ((standard == '지원 조건') ? (etc = '자세히 보기') : null);
              return _buildCriteriaCard('${widget.university} ', standard, standardContents, etc);
            }),
          ],
        )
        : Container(
          color: intermediateBackgroundColor,
          child: Center(
            child: Text('아직 ${widget.university}의 지원 조건/선발 기준 섹션은 지원되고 있지 않습니다.'),
          ),
        ),
      ],
    );
  }
  Widget _buildCriteriaCard(String university, String standard, List<dynamic> standdardContents, String etc) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.5), width: 0.35),
        color: intermediateBackgroundColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: university,
              style: TextStyle(color: Colors.black, fontSize: 17),
              children: [
                TextSpan(
                  text: standard,
                  style: TextStyle(color: Colors.black, fontSize: 17),
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
              child: Text(etc, style: TextStyle(fontSize: 15)),
            ),
          ]
        ],
      ),
    );
  }
}