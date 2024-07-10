import 'package:cloud_firestore/cloud_firestore.dart';

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
  '2024-2 파견학생 TOEFL ITP 2차' : Timestamp.fromDate(DateTime(2024, 07, 19, 15, 00)),
  '2024-2 파견학생 TOEFL ITP 2차 성적 발표' : Timestamp.fromDate(DateTime(2024, 07, 26, 15, 00)),
  '2024-2 선발전형 확정공지 (7월 3주차)' : Timestamp.fromDate(DateTime(2024, 07, 20)),
  '2024-2 온라인 접수 (8월 1~2주차)' : Timestamp.fromDate(DateTime(2024, 08, 01)),
};

Map<String, Map<String, String>> gijun = {
  '선발 기준' : {
    '1' : '누계 평점 (40%) + 어학성적 (40%) + 서류 (20%)',
    '2' : '영미권/유럽권: 어학은 공인어학성적 점수로 환산',
    '3' : '중국어권/일본어권: 별도의 어학시험 실시',
    '4' : '서류: 지원동기/학업계획 + 대표성 + 발전가능성/효과성',
  },
  '가산점' : {
    '1' : '원어강의 과목 당 0.5점의 가산점 부여',
    '2' : '최대 3점',
    '3' : '정규 및 게절학기 모두 인정',
    '4' : '교양/전공 어학관련 영어회화 과목 미 인정',
  },
  '지원 조건' : {
    '1' : '학부생: 2.7 / 4.3',
    '2' : '학부생: 2~6학기 이수',
    '4' : '대학원생: 본교 2학기 이상 이수',
    '5' : '대학원생: 3.0 / 4.3',
    '6' : '편입생: 본교 1학기 이상 이수',
    '7' : '재학생 및 휴학생 모두 지원 가능',
  },
  '지원 불가 조건' : {
    '1' : '학칙 상 징계 존재 (학사 경고 제외)',
    '2' : '해외 여행에 결격 사유 존재',
    '3' : '기존 국제교류 프로그램 합격 후 중도 포기자',
  },
  '제출 가능 어학성적 및 커트라인' : {
    '1' : '영어권: CBT 200 이상 or TOEFL iBT 72 이상 or TOEFL ITP 533 이상 or IELTS Academic 6.0 이상',
    '2' : 'TOEFL / IELTS / HSK: 파견교 개강일 기준 2년 이내 성적만 인정',
    '3' : 'TOEFL ITP: 본교 기관토플 성적만 인정',
  },
};

/*
void univAdder() async {
  await FirebaseFirestore.instance.collection('universities').doc('숙명여자대학교').update({
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