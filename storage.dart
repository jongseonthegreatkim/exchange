import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/*
Map<String, Map<String, String>> sangDaeGyo = {
  '영미권':
  '유럽권':
  '일본' :
  '기타':
  '중국어권':
};
*/

Map<String, Timestamp> iljeong = {
  '2025-1 합격자 발표 및 수락서명 시작' : Timestamp.fromDate(DateTime(2024, 07, 24, 13, 00)),
  '2025-1 합격자 발표 및 수락서명 마감' : Timestamp.fromDate(DateTime(2024, 07, 26, 15, 00)),
  '2025-1 추가모집 공지' : Timestamp.fromDate(DateTime(2024, 08, 01, 00, 00)),
  '2025-1 추가모집 시작' : Timestamp.fromDate(DateTime(2024, 08, 01, 09, 00)),
  '2025-1 추가모집 마감' : Timestamp.fromDate(DateTime(2024, 08, 02, 23, 59)),
  '2025-1 추가합격자 발표' : Timestamp.fromDate(DateTime(2024, 08, 12, 00, 00)),
};

Map<String, Map<String, String>> gijun = {
  '지원 조건' : {
    '1' : '학부생: 2.8/4.5 이상',
    '2' : '학부생: 2학기 이상 이수 (편입생 1학기)',
    '3' : '대학원생: 3.0/4.5 이상',
    '4' : '대학원생: 1학기 이상 이수',
    '5' : '마지막 학기는 본교에서 이수 (4-2 파견 후 초과학기로 졸업 가능)',
  },
  '지원 불가 조건' : {
    '1' : '전문대학원생, 특수대학원생, 논문학기자, 박사과정자',
  },
  '선발 기준' : {
    '1' : '1차: 본교 지원 조건 및 각 대학별 요건 충족',
    '2' : '2차: 학업계획서(50%) + 학점 (50%)',
    '3' : '학업계획서: 학업계획(20%) + 지원동기(15%) + 졸업후계획(15%)',
  },
  '제출 가능 어학성적 및 커트라인' : {
    '11' : '영어권',
    '12' : '학부생: TOEFL iBT 79 이상 or IELTS Academic 6.0 이상',
    '13' : '대학원생: TOEFL iBT 88 이상 or IELTS Academic 6.5 이상',
    '14' : '2023.01.01. 이후 성적만 유효',
    '21' : '비영어권',
    '22' : '해당국가 언어 중급 이상',
    '26' : '2020.01.01. 이후 성적만 유효',
  },
  '비영어권 어학성적' : {
    '11' : '1. 파견교 요구 성적표 제출하는 경우',
    '12' : 'DALF / ZD: 알파벳 레벨은 표기하지 않고 숫자만 제출',
    '13' : '요구사항이 없을 때: Language Proficiency Repot 제출',
    '21' : '2. 본교의 중급/고급 level의 해당 언어 과목 성적표를 제출하는 경우',
    '22' : '본교 영문 성적표 1부 제출 (해당 과목 하이라이트)',
    '23' : '국어 강의 제외',
    '24' : '파견교가 중급을 요구하는 지 고급을 요구하는 지 확인',
    '25' : '영문 성적표 상 level이 표기되지 않는다면, 강의계획서 첨부 필요',
    '31' : '3. 외부 기관의 중급/고급 level의 해당 언어 강좌 성적표를 제출하는 경우',
    '32' : '각 과목 당 80시간 이상 수강',
    '33' : '총 160시간 수강',
    '34' : '대학 입학 후 수강한 과목에 한함',
    '41' : '2, 3번은 1과목씩 조합도 가능',
    '51' : '중국어권에 지원하는 중국국적자는 중국국적지원자HSK성적미소지사유서 제출',
  },
  '가산점' : {
    '1' : '활동 기간 표기 필수!',
    '2' : 'KUBA/KUSIA 1학기 이상',
    '3' : '한국어 도우미 10시간 이상',
    '4' : '본교 국제 하/동계 대학 버디, 조교',
    '5' : 'GSC 멘토 장학생',
    '6' : '여울',
    '7' : '2021년 GLP 프로그램 참가자',
    '8' : '2021년 국제교류팀 비대면교류프로그램 참가자',
    '9' : '2023년까지 ISC,IWC 참가자',
  },
  '감점' : {
    '1' : '첨부서류 미비',
    '2' : '어학성적을 캡쳐본으로 제출 (어학 성적표가 발급 되지 않은 자 제외)',
    '3' : '지원서의 어학 점수와 증빙한 어학성적표의 점수가 다름',
    '4' : '신청서 제출 완료 후 수정을 위해 전 단계로 변경 요청 시',
  },
};

/*
void univAdder() async {
  await FirebaseFirestore.instance.collection('universities').doc().update({
    '상대교' : sangDaeGyo,
    '일정' : iljeong,
    '기준' : gijun,
  });
}
@override
void initState() {
  super.initState();
  univAdder();
}
*/

/// FlutterLocalNotification
/*
TextButton(
  onPressed: () {
    FlutterLocalNotification.showNotification('교환하냥', '안녕하세요?');
  },
  child: const Text('알림 보내기'),
),
*/

Color backgroundColor = Colors.white;
Color conceptColor = Color(0xFF73A9DA);
Color conceptBackgroundColor = Color(0xFFF5DADA);