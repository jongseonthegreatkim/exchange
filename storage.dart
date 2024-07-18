import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Map<String, Map<String, String>> sangDaeGyo = {
  '영미권': {
    'CARLETON UNIVERSITY': 'https://carleton.ca/isso/incoming-student-exchange-program/',
    'TEMPLE UNIVERSITY': 'https://globalprograms.temple.edu',
    'KING UNIVERSITY': 'https://www.king.edu/student-life/resources-for-students/international-students/',
    'Georgia Gwinnett College': 'https://www.ggc.edu/academics/internationalization/education-abroad-at-ggc',
    'UNIVERSITY OF HAWAI\'I AT HILO': 'https://hilo.hawaii.edu/exchange/international/',
    'MEMORIAL UNIVERSITY OF NEWFOUNDLAND(ST. JOHN\'S CAMPUS)': 'https://www.mun.ca/goabroad/',
    'ALBRIGHT COLLEGE': 'https://www.albright.edu/admission-aid/international-students/',
    'UNIVERSITY OF CALIFORNIA, DAVIS': 'https://globalstudy.ucdavis.edu/',
    'Boston University Metropolitan College': 'https://www.bu.edu/metinternational/',
    'NORTHERN KENTUCKY UNIVERSITY': 'https://inside.nku.edu/internationalstudents.html',
    'Universidad San Francisco de Quito': 'https://www.usfq.edu.ec/en/opi/international/international-students/academic-programs/semester',
    'COE COLLEGE': 'https://www.coe.edu/student-life/student-life-resources/international-student-affairs',
    'CALIFORNIA STATE UNIVERSITY, FULLERTON': 'https://extension.fullerton.edu/international/',
    'UNIVERSITY OF NEVADA, RENO': 'https://www.unr.edu/oiss',
    'FLORIDA STATE UNIVERSITY': 'https://globalexchanges.fsu.edu',
    'ANGELO STATE UNIVERSITY': 'https://www.angelo.edu/life-on-campus/explore/center-for-international-studies/',
    'UNIVERSIDAD DE MONTERREY': 'https://www.udem.edu.mx/en/study/udem-for-one-semester',
    'UNIVERSITY OF SYDNEY': 'https://www.sydney.edu.au/study/why-choose-sydney/study-abroad-and-exchange.html',
    'UNIVERSITY OF SOUTH AUSTRALIA': 'https://unisa.edu.au/global-experiences/study-abroad-and-exchange-at-unisa/',
    'WESLEYAN COLLEGE': 'https://www.wesleyancollege.edu/admission/undergraduate/international/exchangeinternational.cfm',
    'CORNELL COLLEGE': 'https://www.cornellcollege.edu/admissions/apply-to-cornell/international/index.shtml',
    'UNIVERSITY OF FORTALEZA - UNIFOR': 'https://unifor.br/web/guest/international/exchange-students#tabs',
    'UNIVERSITY OF WISCONSIN-MADISON': 'https://visp.wisc.edu/',
    'ROYAL ROADS UNIVERSITY': 'https://www.royalroads.ca/current-students/study-abroad/inbound-student-exchange',
    'CALIFORNIA STATE POLYTECHNIC UNIVERSITY, POMONA (CAL POLY POMONA)': 'https://www.cpp.edu/cpge/semesteratcpp/index.shtml',
    'STOCKTON UNIVERSITY': 'https://stockton.edu/global-engagement/international/index.html',
  },
  '유럽권': {
    'DANISH SCHOOL OF MEDIA AND JOURNALISM': 'https://www.dmjx.dk/international/coming-denmark',
    'THE UNIVERSITY OF SHEFFIELD': 'https://www.sheffield.ac.uk/globalopps/inbound',
    'UNIVERSITY OF UDINE': 'https://www.uniud.it/en/uniud-international/incoming-exchange-students',
    'UNIVERSITY OF BERN': 'https://www.unibe.ch/studies/mobility/incoming/worldwide/worldwide_exchange/index_eng.html',
    'YORK ST JOHN UNIVERSITY': 'https://www.yorksj.ac.uk/international/study-abroad-and-exchange/study-abroad-at-york-st-john/',
    'UNIVERSITY OF SKÖVDE': 'https://www.his.se/en/education/admission/exchange-student/',
    'Artevelde University of Applied Sciences': 'https://www.artevelde-uas.be/',
    'UNIVERSITÉ\xa0RENNES 2': 'https://www.univ-rennes2.fr/formation/venir-etudier-france/etudiantes-echange-inscriptions',
    'UNIVERSITY OF BOURGOGNE (*CIEF)': 'https://cief.u-bourgogne.fr/',
    'PARIS NANTERRE UNIVERSITY (UNIVERSITÉ\xa0PARIS NANTERRE)': 'https://university.parisnanterre.fr/international-student-studying-at-paris-nanterre/incoming-exchange-students',
    'UNIVERSITY OF TUEBINGEN': 'https://uni-tuebingen.de/en/international/study-in-tuebingen/erasmus-and-exchange-to-tuebingen/',
    'UNIVERSITY OF BAMBERG': 'https://www.uni-bamberg.de/en/studies/exchange-students-eg-erasmus/',
    'GROUPE EDH - EFAP': 'https://www.efap.com/en/international-school',
    'UNIVERSITY OF LE HAVRE': 'https://www.univ-lehavre.fr/spip.php?rubrique47',
    'LORENZO DE\' MEDICI': 'https://ldminstitute.com/',
    'ULM UNIVERSITY': 'https://www.uni-ulm.de/en/io/mobility-incomings/planning-to-study-abroad/why-choose-ulm/',
    'Fontys Academy for the Creative Economy': 'https://www.fontys.nl/en/Cluster-Economics.htm',
    'EMBA - ISUGA': 'www.emba-bs.com',
    'THE UNIVERSITY OF MANCHESTER': 'https://www.manchester.ac.uk/study/international/study-abroad-exchange/',
    'WINDESHEIM UNIVERSITY OF APPLIED SCIENCES': 'https://www.windesheim.com/study-programmes/exchange-programmes/application-information',
    'UNIVERSITY OF LONDON': 'https://www.soas.ac.uk/studyabroad',
    'THE HAGUE UNIVERSITY OF APPLIED SCIENCES': 'https://www.thehagueuniversity.com/programmes/other-courses/exchange-programmes',
    'OSNABRÜCK UNIVERSITY (OSNABRUECK UNIVERSITY)': 'https://www.uni-osnabrueck.de/en/prospective-students/international-prospective-students/exchange-and-erasmus-students/?no_cache=1',
    'COPENHAGEN BUSINESS ACADEMY': 'https://www.cphbusiness.dk/english/international-possibilities/cphbusiness-global-semester',
    'METROPOLITAN UNIVERSITY PRAGUE': 'https://www.mup.cz/en/international-cooperation/erasmus-student-exchange/',
    'Rhine-Waal University of Applied Sciences': 'https://www.hochschule-rhein-waal.de/en/international/incoming-exchange-students',
    'LEIDEN UNIVERSITY': 'https://www.universiteitleiden.nl/en/education/admission-and-application/exchange',
    'TOULOUSE CATHOLIC UNIVERSITY': 'https://www.ict-toulouse.fr/en/international-student/',
    'FURTWANGEN UNIVERSITY': 'https://www.hs-furtwangen.de/en/planning/international/international-students/',
    'AVIGNON UNIVERSITY': 'https://univ-avignon.fr/international/etudiants-etrangers/etudiants-en-echange-incoming-exchange-students/',
    'UNIVERSITE DE TECHNOLOGIE DE TROYE(UTT)': 'https://www.utt.fr/study-at-utt',
    'FRANKFURT UNIVERSITY OF APPLIED SCIENCES': 'https://www.frankfurt-university.de/en/studies/international-office/incomings/exchange/',
    'CY CERGY PARIS UNIVERSITY': 'https://en.cy-ecolededesign.fr/formations',
    'UNIVERSITA CA\'FOSCARI VENEZIA': 'https://www.unive.it/pag/12574',
    'Universidad CEU San Pablo': 'https://www.uspceu.com/en/international/international-mobility/incoming-mobility',
    'ICES, CATHOLIC UNIVERSITY OF VENDÉE': 'https://ices-university.com',
    'DEGGENDORF INSTITUTE OF TECHNOLOGY': 'https://th-deg.de/exchange-students',
    'LUDWIGSHAFEN UNIVERSITY OF BUSINESS AND SOCIETY': 'https://www.hwg-lu.de/international/exchange-students-from-partner-institutions',
  },
  '일본' : {
    'OSAKA GAKUIN UNIVERSITY': 'https://www.ogu.ac.jp/english/int_exchange/index.html',
    'HIROSHIMA JOGAKUIN UNIVERSITY': 'https://sites.google.com/gaines.hju.ac.jp/hju-international-office#h.m6b2flar11tf',
    'Ritsumeikan Asia Pacific University': 'https://en.apu.ac.jp/abroad/prospective/incoming/',
    'HIROSHIMA SHUDO UNIVERSITY': 'https://www.shudo-u.ac.jp/international/index.html',
    'KINJO GAKUIN UNIVERSITY': 'https://kinjo-ciep.net/',
    'KOBE COLLEGE': 'https://www.kobe-c.ac.jp/ekc/index.html',
    'TAMA UNIVERSITY': 'https://www.tama.ac.jp/international/index.html',
    'YOKOHAMA NATIONAL UNIVERSITY': 'https://www.ynu.ac.jp/english/education/other/joy/',
    'MEIJI UNIVERSITY': 'https://www.meiji.ac.jp/cip/english/admissions/exchange.html',
    'KYUSHU UNIVERSITY': 'http://kyoso.kyushu-u.ac.jp/en/',
    'KANSAI GAIDAI UNIVERSITY': 'https://www.kansaigaidai.ac.jp/asp/',
    'AICHI SHUKUTOKU UNIVERSITY': 'https://www.aasa.ac.jp/institution/international/en/',
  },
  '기타': {
    'HANOI UNIVERSITY': 'http://internationaloffice.hanu.vn/',
    'UNIVERSITI BRUNEI DARUSSALAM': 'https://ubd.edu.bn/admission/international-exchange/student-exchange-programme/',
    'Chulalongkorn University': 'https://bba.acc.chula.ac.th/index.php/2014-06-27-06-11-06/study-abroad-program/incoming',
    'UNIVERSITY OF GHANA': 'https://ipo.ug.edu.gh/',
    'SAF(study abroad Foundation)': 'http://korea.studyabroadfoundation.org/',
    'UNIVERSITY OF MALAYA': 'https://gem.um.edu.my/inbound-long-term-home',
    'LINGNAN UNIVERSITY': 'http://www.ln.edu.hk/oge/incoming_stu/',
    'GROUPE ISCAE': 'www.groupeiscae.ma',
    'NANYANG TECHNOLOGICAL UNIVERSITY': 'https://gem.ntu.edu.sg/index.cfm?FuseAction=Programs.ViewProgramAngular&id=10006',
    'University of Asia and the Pacific': 'https://uap.asia/international#policy',
    'KIMEP': 'https://www.kimep.kz/diam/en/',
    'J.F.OBERLIN UNIVERSITY': 'https://j-f-oberlin-university.notion.site/J-F-Oberlin-University-Application-guideline-for-student-exchange-program-88be662d9fcb43e4a1d91fa1e9e009e0',
  },
  '중국어권': {
    'DONGHUA UNIVERSITY': 'https://ices.dhu.edu.cn/',
    'SHANDONG UNIVERSITY (JINAN)': 'https://ipo.wh.sdu.edu.cn/kristudy/index.htm',
    'SHANDONG UNIVERSITY (WEIHAI)': 'https://ipo.wh.sdu.edu.cn/kristudy/index.htm',
    'SOOCHOW UNIVERSITY': 'https://international.suda.edu.cn',
    'GUANGDONG UNIVERSITY OF FOREIGN STUDIES\xa0': 'https://internationaloffice.gdufs.edu.cn/',
    'NATIONAL TAIWAN NORMAL UNIVERSITY': 'https://bds.oia.ntnu.edu.tw/bds/en/web\xa0',
    'NATIONAL CENTRAL UNIVERSITY': 'https://www.ncu.edu.tw/en/index.php',
    'NATIONAL UNIVERSITY OF KAOHSIUNG': 'http://dia.nuk.edu.tw/',
    'NATIONAL CHENGCHI UNIVERSITY (NCCU)': 'https://oic.nccu.edu.tw/Post/833',
    'CHINESE CULTURE UNIVERSITY': 'https://oima.pccu.edu.tw/',
    'MINZU UNIVERSITY OF CHINA': 'https://oir.muc.edu.cn/en',
    'NANJING NORMAL UNIVERSITY': 'https://en.njnu.edu.cn/admissions',
    'LANZHOU UNIVERSITY': 'https://en.lzu.edu.cn/',
    'NATIONAL TAIWAN UNIVERSITY OF SCIENCE AND TECHNOLOGY': 'https://oia-r.ntust.edu.tw/p/412-1060-8919.php?Lang=en',
    'ZHEJIANG NORMAL UNIVERSITY': 'http://wsc.zjnu.edu.cn/main.htm',
    'NATIONAL CHIN-YI UNIVERSITY OF TECHNOLOGY': 'https://n030.ncut.edu.tw/?Lang=en',
    'YANCHENG TEACHERS UNIVERSITY': 'https://gjc.yctu.edu.cn/',
    'PROVIDENCE UNIVERSITY': 'https://oia.pu.edu.tw/app/home.php',
    'NATIONAL CHI NAN UNIVERSITY': 'https://oia.ncnu.edu.tw/?Lang=zh-tw',
    'SICHUAN INTERNATIONAL STUDIES UNIVERSITY': 'https://sisu.at0086.cn/StuApplication/Login.aspx',
    'DALIAN UNIVERSITY OF FOREIGN LANGUAGE': 'https://scs.dlufl.edu.cn',
    'COMMUNICATION UNIVERSITY OF CHINA': 'https://international.cuc.edu.cn/',
    'SHIH CHIEN UNIVERSITY': 'https://uscoia.usc.edu.tw/p/412-1049-1074.php?Lang=zh-tw',
    'BEIJING INSTITUTE OF TECHNOLOGY': 'https://international.bit.edu.cn/',
    'HARBIN UNIVERSITY OF SCIENCE AND TECHNOLOGY': 'http://studyinhust.hrbust.edu.cn/\xa0',
  },
};

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