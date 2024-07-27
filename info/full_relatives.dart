import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../colors.dart';

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

  @override
  Widget build(BuildContext context) {

    Map<String, dynamic> relatives = widget.relatives;
    List<String> areas = widget.areas;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
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
            color: AppColors.backgroundColor,
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
                            print(index);
                            Uri url = Uri.parse(urls[index]);
                            await canLaunchUrl(url) ? launchUrl(url) : print('Launch failed: $url');
                          },
                          child: Icon(Icons.arrow_outward)
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
