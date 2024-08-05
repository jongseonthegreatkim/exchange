import 'package:flutter/material.dart';

import '../statics.dart';

class ChangedThings extends StatefulWidget {
  const ChangedThings({super.key, required this.changed, required this.icon});

  final List<dynamic> changed;
  final Image icon;

  @override
  State<ChangedThings> createState() => _ChangedThingsState();
}

class _ChangedThingsState extends State<ChangedThings> {
  @override
  Widget build(BuildContext context) {
    List<dynamic> changed = widget.changed;
    Image icon = widget.icon;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _appBar(context, icon),
      body: _body(context, changed),
      floatingActionButton: _floatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  AppBar _appBar(BuildContext context, Image icon) {
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
                Text('올해 바뀐 기준'),
                icon,
              ],
            ),
          ),
        ],
      ),
      centerTitle: true,
    );
  }

  Widget _body(BuildContext context, List<dynamic> changed) {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Container( // 화면 전체 스크롤을 위함.
        padding: EdgeInsets.only(bottom: 200), // floatingActionButton에 가리지 않기 위함.
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: NeverScrollableScrollPhysics(),
          itemCount: changed.length,
          itemBuilder: (context, index) {
            return _changedThing(changed[index]);
          },
          separatorBuilder: (context, index) {
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

  Widget _changedThing(Map<String, dynamic> changedThing) {
    // 하나씩 밖에 없지만 first를 써서 key와 value에 접근한다.
    String changedTitle = changedThing.keys.first;
    List<dynamic> changedContent = changedThing.values.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            changedTitle,
            style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: NeverScrollableScrollPhysics(),
          itemCount: changedContent.length,
          itemBuilder: (context, index) {

            return RichText(
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
                    text: '  ${changedContent[index]}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
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
