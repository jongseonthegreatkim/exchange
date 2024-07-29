import 'package:flutter/material.dart';

class PaperStandard with ChangeNotifier {
  // private 변수.
  bool _isPaperChecked = false;

  // 외부에서 꺼내 쓰기 위한 getter.
  bool get isPaperChecked => _isPaperChecked;

  // _isPaperChecked 값을 변경하기 위한 함수.
  void changeBoolToTrue() {
    _isPaperChecked = true;
    notifyListeners();
  }
}