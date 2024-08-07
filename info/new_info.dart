import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For DateTime
import 'package:url_launcher/url_launcher.dart'; // For phone call or something.
import 'dart:async'; // For Timer

import 'full_relatives.dart';
import 'paper_to_submit.dart';
import 'standard_page.dart';
import 'changed_things.dart';

import '../statics.dart'; // 모든 전역 상수 저장 장소

class NewInfo extends StatefulWidget {
  const NewInfo({super.key, required this.username, required this.university});

  final String username;
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
      return Center(child: AppLoading.CPI);
    } else {
      return SingleChildScrollView(
        child: Container(
          color: AppColors.white,
          margin: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _scheduleSection(), // ['일정']이 있으면 존재
              _paperBanner(), // ['서류']가 있으면 존재
              _criteriaSection(), // ['조건']이 있으면 존재
              _changedBanner(), // ['변경점']이 있으면 존재
              _relativesSection(), // ['상대교']가 있으면 존재
              _contactBanner(), // ['담당부서 정보']가 있으면 존재
            ],
          ),
        ),
      );
    }
  }

  Widget _scheduleSection() {
    Map<String, dynamic> schedule = universityData!['일정'];

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
            style: AppTextStyle.titleTextStyle,
          ),
          const SizedBox(height: 6),
          Text(
            '현재 ${widget.university}의 남은 일정이 없습니다!',
            style: TextStyle(
              color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppNumbers.infoInterSectionMargin),
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
          style: AppTextStyle.titleTextStyle,
        ),
        const SizedBox(height: 6),
        FittedBox(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$latestKey까지 ',
                  style: TextStyle(
                    color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: displayingLeftoverTime,
                  style: TextStyle(
                    color: Colors.red, fontSize: 15, fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: "남았어요!",
                  style: TextStyle(
                    color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 101,
          child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: [
              ...dateEntries.map((entry) {
                bool _isFirst = false;
                if(entry.key == latestKey)
                  _isFirst = true;
                return _scheduleCard(entry.key, DateFormat('yyyy년 MM월 dd일').format(entry.value), _isFirst);
              }),
            ],
          ),
        ),
        SizedBox(height: AppNumbers.infoInterSectionMargin),
      ],
    );
  }
  Widget _scheduleCard(String title, String date, bool _isFirst) {
    Color _backgroundColor = _isFirst ? AppColors.backgroundColor : AppColors.white;
    Color _borderColor = _isFirst ? AppColors.keyColor.withOpacity(0.1) : Colors.grey.withOpacity(0.1);

    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: _backgroundColor,
        border: Border.all(color: _borderColor, width: AppNumbers.borderWidth),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyle.subtitleTextStyle,
          ),
          Text(
            date,
            style: AppTextStyle.contentTextStyle,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('기능 준비 중입니다!')));
            },
            child: Text(
              '캘린더에 추가',
              style: AppTextStyle.mediumTextStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paperBanner() {
    Map<String, dynamic>? paper = universityData!['서류'];

    // 아직 '서류' 필드가 준비되지 않은 대학교의 경우
    if(paper == null)
      return const SizedBox();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: AppNumbers.infoInterSectionMargin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PaperToSubmit(
              university: widget.university,
              leftoverPapers: leftoverPapers,
              donePapers: donePapers,
              warnings: paper['주의사항'],
              icon: Icon(Icons.subject, color: Colors.black, size: 30),
            )),
          );
        },
        child: Row(
          children: [
            (_isFieldExist == true)
                ? const Icon(Icons.warning, color: Color(0xFFDA3B3B), size: 30)
                : const Icon(Icons.subject, color: Colors.black, size: 30),
            const SizedBox(width: 10),
            Text(
              (_isFieldExist == true)
                  ? '아직 준비 하지 못한 서류 ${leftoverPapers.length}가지\n다시 확인하기'
                  : '${widget.university} 제출 서류\n1분 만에 확인하기',
              style: AppTextStyle.subtitleTextStyle,
            ),
          ],
        ),
        style: AppButtonStyle.paperButtonStyle,
      ),
    );
  }

  Widget _criteriaSection() {
    Map<String, dynamic>? criteria = universityData!['조건'];

    if(criteria == null)
      return const SizedBox();

    // 선발기준, 주의사항, 지원서 작성방법, 지원조건 등 (해당은 건국대 기준)
    List<String> _keys = criteria.keys.toList();

    return Container(
      margin: EdgeInsets.only(bottom: AppNumbers.infoInterSectionMargin),
      // set bottom padding as zero as _criteriaCard has its own padding.
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.secondBackgroundColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.username}님을 위해 준비한 ${_keys.length}가지 꿀팁',
            style: AppTextStyle.subtitleTextStyle,
          ),
          const SizedBox(height: 5),
          ..._keys.map((key) {
            List<dynamic> value = criteria[key];

            return _criteriaBanner(key, value);
          })
        ],
      ),
    );
  }
  Widget _criteriaBanner(String key, List<dynamic> value) {
    late Icon _criteriaIcon;
    late String _title;

    if(key == '선발기준') {
      _criteriaIcon = const Icon(Icons.accessibility, color: Color(0xFFD2B19D), size: 20);
      _title = '선발기준 알아보기';
    }
    if(key == '지원서 작성방법') {
      _criteriaIcon = const Icon(Icons.newspaper, color: Color(0xFF565151), size: 20);
      _title = '지원서 작성하는 방법';
    }
    if(key == '지원조건') {
      _criteriaIcon = const Icon(Icons.account_box_rounded, color: Color(0xFF9BA0D7), size: 20);
      _title = '지원조건 체크하기';
    }
    if(key == '주의사항') {
      _criteriaIcon = const Icon(Icons.warning, color: Color(0xFFD73F3F), size: 20);
      _title = '지원 시 주의사항은?';
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => StandardPage(
          standardTitle: _title,
          standardContent: value,
          icon: _criteriaIcon,
        )));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            _criteriaIcon,
            const SizedBox(width: 10),
            Text(
              _title,
              style: AppTextStyle.mediumTextStyle,
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 15),
          ],
        ),
      ),
    );
  }

  Widget _changedBanner() {
    List<dynamic>? changed = universityData!['변경점'];

    // 아직 '변경점' 필드가 준비되지 않은 대학교의 경우
    if(changed == null)
      return const SizedBox();

    // 느낌표 이미지
    Image exclamationMark = Image.asset('assets/images/exclamation_mark.png', color: AppColors.keyColor, width: 20, height: 25);


    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: AppNumbers.infoInterSectionMargin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.3), width: AppNumbers.borderWidth),
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChangedThings(
              changed: changed,
              icon: exclamationMark,
            )),
          );
        },
        child: Row(
          children: [
            exclamationMark,
            const SizedBox(width: 13),
            Text(
              '${widget.university}에서\n올해 처음 바뀐 기준 ${changed.length}가지',
              style: AppTextStyle.subtitleTextStyle,
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.secondBackgroundColor.withOpacity(0.75),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                '확인하기',
                style: AppTextStyle.mediumTextStyle,
              ),
            ),
          ],
        ),
        style: AppButtonStyle.changedButtonStyle,
      ),
    );
  }

  Widget _relativesSection() {
    Map<String, dynamic>? relatives = universityData!['상대교'];

    if(relatives == null)
      return const SizedBox();

    List<String> areas = relatives.keys.toList();

    return Container(
      margin: EdgeInsets.only(bottom: AppNumbers.infoInterSectionMargin),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.3), width: AppNumbers.borderWidth),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '상대교 국제처 링크 모음',
                  style: AppTextStyle.subtitleTextStyle,
                ),
                GestureDetector(
                  onTap: () {
                    // 지원 가능 대학 목록 전체 보기
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FullRelatives(
                      relatives: relatives,
                      areas: areas,
                    )));
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 2),
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.secondBackgroundColor.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        '전체보기',
                        style: AppTextStyle.mediumTextStyle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 94,
            child: ListView(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              children: [
                ...areas.map((area) {
                  List universitiesInArea = relatives[area].keys.toList();

                  // previewSplit개 만큼만 universitiesInArea에서 떼 올 예정
                  int previewSplit = (universitiesInArea.length >= 3) ? 3 : universitiesInArea.length;

                  // 떼 온 값을 previewUnivList에 넣는다
                  List previewUnivList = universitiesInArea.sublist(0, previewSplit);

                  return _relativesCard(area, previewUnivList, relatives);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _relativesCard(String title, List<dynamic> universities, Map<String, dynamic> relatives) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 10),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$title 대학',
            style: AppTextStyle.mediumTextStyle,
          ),
          const SizedBox(height: 8),
          ...universities.map((university) =>
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    /// 해당 대학으로 넘어가는 함수.
                  },
                  child: Text(
                    university,
                    style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 13, fontWeight: FontWeight.w600, overflow: TextOverflow.ellipsis),
                  ),
                ),
                if(universities.indexOf(university) != universities.length-1)...[
                  const SizedBox(height: 5),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactBanner() {
    Map<String, dynamic>? contact = universityData!['담당부서 정보'];

    if(contact == null)
      return const SizedBox();

    List<String> desiredOrderOfContactType = ['전화번호', '이메일', '위치', '우편번호'];

    // Create a nnw map with the desired order
    Map<String, dynamic> orderedContact = {};
    for(String key in desiredOrderOfContactType) {
      if(contact.containsKey(key))
        orderedContact[key] = contact[key];
    }

    // 정보 종류
    List<String> contactType = orderedContact.keys.toList();
    // 정보 타입
    List<dynamic> contactContent = orderedContact.values.toList();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.3), width: AppNumbers.borderWidth),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '담당부서 정보',
            style: AppTextStyle.subtitleTextStyle,
          ),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: contactContent.length,
            itemBuilder: (context, index) {
              return Container(
                height: 20,
                child: ElevatedButton(
                  onPressed: () async {
                    await _contactOnTap(contactType[index], contactContent[index]);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _contactIcon(contactType[index]),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${contactContent[index]}',
                            style: TextStyle(
                              color: (contactType[index] == '전화번호') ? Colors.green : ((contactType[index] == '이메일') ? Colors.grey : Colors.black),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  style: AppButtonStyle.buttonStyle,
                ),
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(height: 7);
            },
          ),
        ],
      ),
    );
  }
  Icon _contactIcon(String contactType) {
    // contactType[index]를 icon으로 바꾸는 곳

    if(contactType == '전화번호')
      return const Icon(Icons.call, color: Colors.green, size: 20);
    if(contactType == '이메일')
      return const Icon(Icons.alternate_email, color: Colors.grey, size: 20);
    if(contactType == '위치')
      return const Icon(Icons.location_on, color: Colors.blue, size: 20);
    if(contactType == '우편번호')
      return const Icon(Icons.mail, color: Colors.orange, size: 20);

    // 위 경우가 아닐 때, 기본적으로 리턴할 아이콘
    return const Icon(Icons.circle_outlined, color: Colors.black, size: 20);
  }
  Future<void> _contactOnTap(String contactType, String contactContent) async {
    // contactType[index]에 따라, 버튼을 눌렀을 때 액션이 보여지게 하는 곳

    if(contactType == '전화번호') {
      Uri url = Uri(
        scheme: 'tel',
        path: contactContent,
      );
      await canLaunchUrl(url) ? launchUrl(url) : print('Telephone app launch failed: $url');
    }
    if(contactType == '이메일') {
      Uri url = Uri(
        scheme: 'mailto',
        path: contactContent,
      );
      await canLaunchUrl(url) ? launchUrl(url) : print('Mail app launch failed: $url');
    }
  }
}