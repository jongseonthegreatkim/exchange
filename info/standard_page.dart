import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../statics.dart';

class StandardPage extends StatefulWidget {
  const StandardPage({super.key, required this.standardTitle, required this.standardContent, required this.icon});

  final String standardTitle;
  final List<dynamic> standardContent;
  final Icon icon;

  @override
  State<StandardPage> createState() => _StandardPageState();
}

class _StandardPageState extends State<StandardPage> {
  @override
  Widget build(BuildContext context) {

    String standardTitle = widget.standardTitle;
    List<dynamic> standardContent = widget.standardContent;
    Icon icon = widget.icon;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _appBar(context, standardTitle, icon),
      body: _body(context, standardTitle, standardContent),
      floatingActionButton: _floatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  AppBar _appBar(BuildContext context, String standardTitle, Icon icon) {
    return AppBar(
      backgroundColor: AppColors.white,
      scrolledUnderElevation: 0, // Disable light background color when we scroll body upward.
      automaticallyImplyLeading: false,
      title: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back_ios_new_rounded),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                SizedBox(width: 10),
                Text(standardTitle),
              ],
            ),
          ),
        ],
      ),
      centerTitle: true,
    );
  }

  Widget _body(BuildContext context, String standardTitle, List<dynamic> standardContent) {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Container( // 화면 전체 스크롤을 위함.
        padding: EdgeInsets.only(bottom: 200), // floatingActionButton에 가리지 않기 위함.
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: NeverScrollableScrollPhysics(),
          itemCount: standardContent.length,
          itemBuilder: (context, index) {
            String middleTitle = standardContent[index].keys.first;
            List<dynamic> middleContent = standardContent[index].values.first;

            return _middle(middleTitle, middleContent);
          },
          separatorBuilder: (context, index) {
            List<dynamic> middleContent = standardContent[index].values.first;
            if(middleContent.length == 0)
              return SizedBox();

            return Container(
              margin: EdgeInsets.symmetric(vertical: 15),
              width: double.infinity,
              height: 1,
              color: Colors.grey,
            );
          },
        ),
      ),
    );
  }

  Widget _middle(String middleTitle, List<dynamic> middleContent) {
    if(middleContent.length == 0)
      return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            middleTitle,
            style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: NeverScrollableScrollPhysics(),
          itemCount: middleContent.length,
          itemBuilder: (context, index) {

            return GestureDetector(
              onTap: () async {
                if(middleTitle == '링크') {
                  Uri url = Uri.parse(middleContent[index]);
                  await canLaunchUrl(url) ? launchUrl(url) : print('Launch failed: $url');
                }
              },
              child: RichText(
                text: TextSpan(
                  children: [
                    WidgetSpan(
                      child: Icon(
                        Icons.circle,
                        size: 8,
                        color: Colors.black,
                      ),
                      alignment: PlaceholderAlignment.middle,
                    ),
                    TextSpan(
                      text: '  ${middleContent[index]}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (context, index) {
            return SizedBox(height: 15);
          },
        ),
      ],
    );
  }

  ElevatedButton _floatingActionButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: Text('확인 완료', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      style: ButtonStyle(
        padding: WidgetStateProperty.resolveWith((states) {
          return EdgeInsets.symmetric(horizontal: 30);
        }),
        // foregroundColor = TextStyle(color), overlayColor = color when overlayed
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          return Colors.black.withOpacity(0.8);
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          return AppColors.secondBackgroundColor;
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          return Colors.grey.withOpacity(0.1);
        }),
      ),
    );
  }
}
