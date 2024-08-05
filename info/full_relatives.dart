import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../statics.dart';

class FullRelatives extends StatefulWidget {
  const FullRelatives({super.key, required this.relatives, required this.areas});

  final Map<String, dynamic> relatives;
  final List<String> areas;

  @override
  State<FullRelatives> createState() => _FullRelativesState();
}

class _FullRelativesState extends State<FullRelatives> {
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  Map<String, dynamic> jogun = {
    '선발기준' : [
      {
        '선발기준' : [
         '서류전형 (70%) + 면접전형 (30%)',
         '서류전형 - 자기소개서 (10%) + 평점평균 (30%) + 어학성적 (30%)',
         '면접전형 - 1인당 10분 내외',
         '동점자 처리기준: 평점평균 > 어학성적 > 이수학기',
        ],
      },
      {
        '가산점' : [

        ],
      },
      {
        '감점' : [

        ],
      },
    ],
    '주의사항' : [
      {
        '문서' : [
          '일반 학부생 - 최대 2개 학기 해외 수학 가능',
          '학부 편입생 - 최대 1개 학기 해외 수학 가능',
          '본교 기준 7학기까지 해외에서 수학 가능. 8학기는 예외 없이 본교에서 반드시 수학',
          '해외대학에서 취득한 학점은 본교 평균평점에 반영되지 않고 졸업이수학점에만 포함됨',
          '유럽학점이수체계(ECTS) - 1 ECTS = 2/3 본교 학점',
          '오리엔테이션 불참 시 합격 취소',
          '일부 지역 파견 대상교는 총평점평균 3.5/4.5 이상 혹은 소정의 전공 이수학점 기준 별도 요구',
          '사범대학 소속 학생(및 교직과정 이수자 포함)은 해외파견 프로그램 참가에 따른 교원 자격증 취득 가능 여부를 반드시 확인 후 지원',
          '공학계열 일부 학과(학부)(사회환경공학부, 기계항공공학부, 전기전자공학부, 화학공학부, 산업공학과)의 경우, 공학교육인증(ABEEK) 심화 프로그램 이수가 의무이므로 해당 학과(학부) 소속 학생은 해외파견 프로그램 참가 시, 공학교육 인증 심화 프로그램 이수요건 충족 여부 및 인증학점 인정 등에 관한 세부사항에 대해 공학교육연구소의 학과별 공학교육인증 심화 프로그램 담당 조교(02-2049-6104, 6105) 및 학과별 PD(Program Director)교수와 반드시 사전 상담 요망',
          '해외파견 프로그램 참가에 따라 각종 교내·외 장학금(국가장학금 포함) 신청 및 수혜에 결격사유가 발생할 수 있으므로 유관부서와 반드시 사전 상담 요망',

        ],
      },
      {
        '링크' : [
          'https://www.konkuk.ac.kr/oia/18778/subview.do?enc=Zm5jdDF8QEB8JTJGYmJzJTJGb2lhJTJGMTQ3NyUyRjk1NzcyNCUyRmFydGNsVmlldy5kbyUzRnBhZ2UlM0QxJTI2c3JjaENvbHVtbiUzRCUyNnNyY2hXcmQlM0QlMjZiYnNDbFNlcSUzRCUyNmJic09wZW5XcmRTZXElM0QlMjZyZ3NCZ25kZVN0ciUzRCUyNnJnc0VuZGRlU3RyJTNEJTI2aXNWaWV3TWluZSUzRGZhbHNlJTI2cGFzc3dvcmQlM0QlMjY=',
          'https://www.konkuk.ac.kr/oia/18779/subview.do',
        ],
      },
    ],
    '지원서 작성방법' : [
      {
        '지원서 작성방법' : [
          '본교 학사정보시스템 → 학사 → 국제협력 → 교환학생관리(OUTBOUND) → 교류프로그램 신청 → 조회 → 2025.1학기 교환학생 프로그램 → 신청 → 동의서에 동의',
          '→ 희망대학 선택 (1~5개교 + 대륙 간 교차지원 가능 → 지원학교의 자격에 해당하는 모든 어학성적 제출)',
          '→ 어학/경력 입력 (공인어학성적, 국내외 타기관 취득학점, 본교 해외파견 프로그램참가이력 기재 & 어학 기재 시, TOEIC, TOEFL, IELTS, HSK, JLPT라고 기재 (토플, 토익 X))',
          '→ 재정보증인정보 입력',
          '→ 자기소개서 작성 (수학계획 및 포부(지망 대학에서 수학을 희망하는 과목을 구체적으로 명시 + 캠퍼스가 여러 개인 학교의 경우, 어느 캠퍼스의 어느 전공으로 지원하는 지 첫 번째 줄에 반드시 표기) + 성장과정 및 성격의 장단점 + 교내외할동 및 해외여행/수학 경험 + 취미 및 특기) & (각 항목별 공백포함 최소 300자 ~ 최대 400자)',
          '→ 신청',
        ],
      }
    ],
    '지원조건' : [
      {
        '지원조건' : [
          '7학기를 수료하지 않은 자',
          '지원시점 기준 직전학기 12학점 이상 이수한 자(계절학기 학점 제외)',
          '기존 해외파견 프로그램을 통해 2개 정규학기 이상 파견된 적이 없는 자',
          '지원시점 기준 총평점평균 3.0/4.5 이상자',
          '본교 학과(전공) 교육과정과 동일(유사)한 파견 대상교 교육과정 이수 가능자',
          '파견 대상국의 비자신청·발급, 현지 체류에 결격사유가 없는 자',
          '기존 해외파견 프로그램 중도 포기 등으로 인한 지원 제재를 받지 않는 자',
          '해외파견 프로그램 참가 시 조기졸업 불가',
          '외국인의 경우, 본인 국적의 대학으로 지원 불가',
        ],
      },
      {
        '제출가능 어학성적' : [
          '미주 - TOEFL, (IELTS, TOEIC)',
          '유럽 - TOEFL, IELTS, (TOEIC)',
          '중국 - (TOEFL, IELTS, TOEIC), HSK',
          '일본 - (TOEFL, IELTS, TOEIC), JLPT',
          '호주 - TOEFL, IELTS, (TOEIC, HSK)',
          '기타 - TOEFL, IELTS',
        ],
      },
      {
        '어학성적 주의사항' : [
          '괄호 안 쪽은 일부인정',
          '상대교가 요구하는 어학성적 종류 및 커트라인 반드시 확인 요망',
          '상대교가 어학성적을 요구하지 않는 경우 → 최소 1개의 공인영어성적을 제출해야 함.',
          '지원시점 기준 최소 3개월 이상 유효기간이 남아있는 공인어학성적 제출 권장',
          '어학시험에 응시한 지역(국가)의 제한은 없음',
        ],
      },
    ],
  };

  void univAdder() async {
    await FirebaseFirestore.instance.collection('universities').doc('건국대학교').update({
      //'상대교' : sangDaeGyo,
      //'일정' : iljeong,
      //'기준' : gijun,
      //'서류' : seoryu,
      //'조건' : jogun,
    });
  }

  @override
  void initState() {
    super.initState();
    univAdder();
  }

  @override
  Widget build(BuildContext context) {

    Map<String, dynamic> relatives = widget.relatives;
    List<String> areas = widget.areas;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: _isSearching ? false : true,
        title: _isSearching
        ? TextFormField(
          controller: _searchController,
          autofocus: true,
          onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
          decoration: InputDecoration(
            hintText: '대학 이름을 입력하세요',
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.keyColor)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.keyColor)),
          ),
          cursorColor: Colors.black,
          onChanged: (value) {
            setState(() {
              // TextFormField의 값이 바뀔 때 마다, 이를 _searchTerm에 넣어 줌.
              _searchTerm = value.toLowerCase();
            });
          },
        )
        : Text('지원 가능 대학 목록'), // When _isSearching == false
        actions: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isSearching = !_isSearching; // Toogle serach state
                if(!_isSearching) {
                  _searchController.clear(); // Clear serach field when closing
                  _searchTerm = ''; // Reset the _searchTerm
                }
              });
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.only(left: 25, right: 25),
              child: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.black),
            ), // Toggle the icon
          )
        ],
      ),
      body: SafeArea(
        child: Container(
          child: ListView(
            scrollDirection: Axis.vertical,
            children: [
              if(_isSearching) _buildSearchResult(),
              if(!_isSearching) ...areas.map((area) {
                List<MapEntry<String, dynamic>> sortedRelatives = relatives[area].entries.toList()..sort((MapEntry<String, dynamic> a, MapEntry<String, dynamic>b) => (a.key).compareTo(b.key));

                List sortedUniversitiesInArea = sortedRelatives.map((entry) => entry.key).toList();
                List sortedUrlsInArea = sortedRelatives.map((entry) => entry.value).toList();

                // info.dart에서와 달리 전체 목록을 보여줘야 하므로, universitiesInArea전체를 전달한다.
                return _buildFullRelativesCard(area, sortedUniversitiesInArea, sortedUrlsInArea);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResult() {
    Map<String, List<String>> filteredResult = {};

    widget.areas.forEach((area) {
      List<MapEntry<String, dynamic>> sortedRelatives = widget.relatives[area].entries.toList()
        ..sort((MapEntry<String, dynamic> a, MapEntry<String, dynamic> b) => (a.key).compareTo(b.key));

      List<MapEntry<String, dynamic>> filteredRelatives = sortedRelatives.where((entry) {
        return entry.key.toLowerCase().contains(_searchTerm);
      }).toList();

      if(filteredRelatives.isNotEmpty) {
        filteredResult[area] = filteredRelatives.map((entry) => entry.key).toList();
      }
    });

    return Column(
      children: filteredResult.entries.map((entry) {
        String area = entry.key;
        List<String> universities = entry.value;
        List urls = universities.map((university) => widget.relatives[area][university]).toList();

        return _buildFullRelativesCard(area, universities, urls);
      }).toList(),
    );
  }

  // 2.0 업데이트 때 사용할 변수
  late String showingTitle;

  Widget _buildFullRelativesCard(String title, List<dynamic> universities, List<dynamic> urls) {

    showingTitle = '영미권';

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 15),
          child: Text(
            title,
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
        ),
        SizedBox(height: 10),
        Container(
          margin: EdgeInsets.fromLTRB(15, 0, 15, 15),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.withOpacity(0.5), width: 0.35),
            color: AppColors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...universities.map((university) =>
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Flexible widget ensures that the 'Text' widget can shrink to fit within the available space of the row without casuing overflow.
                        Flexible(
                          child: Text(
                            university,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                            ),
                            maxLines: 5,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            int index = universities.indexOf(university);
                            Uri url = Uri.parse(urls[index]);
                            await canLaunchUrl(url) ? launchUrl(url) : print('Launch failed: $url');
                          },
                          child: Icon(Icons.arrow_outward),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider()
      ],
    );
  }
}
