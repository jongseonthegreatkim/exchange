import 'package:flutter/material.dart';

class AppColors {
  static Color white = Colors.white;
  static Color keyColor = Color(0xFFEC8680); // 대학교환 로고 하방 색상
  static Color secondKeyColor = Color(0xFF5BC7DF); // 대학교환 로고 상방 색상
  static Color backgroundColor = Color(0xFFFFF4F3);
  static Color secondBackgroundColor = Color(0xFFD1E0EC);
}

class AppNumbers {
  static double borderWidth = 1.0;
  static double infoInterSectionMargin = 15.0;
  static double profileInterSectionMargin = 20.0;
}

class AppLoading {
  static Widget CPI = CircularProgressIndicator(
    color: AppColors.keyColor,
    backgroundColor: AppColors.white,
  );
}

class AppTextStyle {
  static TextStyle titleTextStyle = TextStyle(
    color: Colors.black, fontSize: 20, fontWeight: FontWeight.w700,
  );
  static TextStyle subtitleTextStyle = TextStyle(
    color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600,
  );
  static TextStyle mediumTextStyle = TextStyle(
    color: Color(0xFF6F6F6F), fontSize: 13, fontWeight: FontWeight.w600,
  );
  static TextStyle contentTextStyle = TextStyle(
    color: Color(0xFF9A9A9A), fontSize: 13, fontWeight: FontWeight.w600,
  );
}

class AppButtonStyle {
  static ButtonStyle paperButtonStyle = ButtonStyle(
    padding: WidgetStateProperty.resolveWith((states) {
      return const EdgeInsets.all(10);
    }),
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      return AppColors.secondBackgroundColor.withOpacity(0.75);
    }),
    overlayColor: WidgetStateProperty.resolveWith((states) {
      return Colors.grey.withOpacity(0.1);
    }),
    elevation: WidgetStateProperty.resolveWith((states) {
      return 0.0;
    }),
    shape: WidgetStateProperty.resolveWith((states) {
      return RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
    }),
  );

  static ButtonStyle changedButtonStyle = ButtonStyle(
    padding: WidgetStateProperty.resolveWith((states) {
      return const EdgeInsets.fromLTRB(15, 10, 20, 10);
    }),
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      return AppColors.white;
    }),
    overlayColor: WidgetStateProperty.resolveWith((states) {
      return Colors.grey.withOpacity(0.1);
    }),
    elevation: WidgetStateProperty.resolveWith((states) {
      return 0.0;
    }),
    shape: WidgetStateProperty.resolveWith((states) {
      return RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
    }),
  );

  static ButtonStyle buttonStyle = ButtonStyle(
    padding: WidgetStateProperty.resolveWith((states) {
      return EdgeInsets.zero;
    }),
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      return AppColors.white;
    }),
    overlayColor: WidgetStateProperty.resolveWith((states) {
      return Colors.grey.withOpacity(0.1);
    }),
    elevation: WidgetStateProperty.resolveWith((states) {
      return 0.0;
    }),
    shape: WidgetStateProperty.resolveWith((states) {
      return RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
    }),
  );
}