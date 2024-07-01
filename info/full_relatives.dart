import 'package:flutter/material.dart';

Color backgroundColor = Color(0xFFF8F7F4);
Color conceptColor = Color(0xFF73A9DA);
Color conceptBackgroundColor = Color(0xFFF5DADA);
Color intermediateBackgroundColor = Color(0xFFfbfff8);

class FullRelatives extends StatefulWidget {
  const FullRelatives({super.key});

  @override
  State<FullRelatives> createState() => _FullRelativesState();
}

class _FullRelativesState extends State<FullRelatives> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        scrolledUnderElevation: 0,
        title: Text('지원 가능 대학 목록'),
      ),
      body: SafeArea(
        child: Container(),
      ),
    );
  }
}
