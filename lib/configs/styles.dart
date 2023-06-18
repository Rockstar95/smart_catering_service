import 'package:flutter/material.dart';

class Styles {
  static final Styles _instance = Styles.newInstance();
  Styles.newInstance();
  factory Styles() => _instance;

  Color lightPrimaryColor = const Color(0xff3F9CCF);
  Color darkPrimaryColor = const Color(0xff3F9CCF);

  Color lightPrimaryVariant = const Color(0xff3F9CCF).withOpacity(0.6);
  Color darkPrimaryVariant = const Color(0xff3F9CCF).withOpacity(0.6);

  Color lightSecondaryColor = Colors.blueAccent;
  Color darkSecondaryColor = Colors.blueAccent;

  Color lightSecondaryVariant = Colors.blueAccent.shade400;
  Color darkSecondaryVariant = Colors.blueAccent.shade400;

  Color lightAppBarTextColor = const Color(0xffffffff);
  Color darkAppBarTextColor = const Color(0xffffffff);

  Color lightTextColor = const Color(0xff495057);
  Color darkTextColor = const Color(0xffffffff);

  Color lightBackgroundColor = const Color(0xffF8F8F8);
  Color darkBackgroundColor = const Color(0xffffffff);

  Color lightAppBarColor = const Color(0xff2680C5);
  Color darkAppBarColor = const Color(0xff2e343b);

  Color lightTextFiledFillColor = Colors.white;
  Color darkTextFiledFillColor = Colors.black;

  Color lightHoverColor = Colors.grey.withOpacity(0.05);
  Color darkHoverColor = Colors.grey.withOpacity(0.5);

  Color lightFocusedTextFormFieldColor = const Color(0xff3F9CCF).withOpacity(0.05);
  Color darkFocusedTextFormFieldColor = const Color(0xff3F9CCF).withOpacity(0.5);

  double buttonBorderRadius = 5;

  //region CustomColors
  Color cardColor = const Color(0xfff0f0f0);
  Color secondaryColor = const Color(0xff084EAD);
  Color myPrimaryColor = const Color(0xff4C508F);
  Color textGrey = const Color(0xff676767);
  //endregion//

  static Color yellow = Color(0xfff7c844);
  static Color bgColor = Color(0xfff8f7f3);
  static const Color bgSideMenu = Color(0xff131e29);
  static Color white = Colors.white;
  static const Color black = Colors.black;

  //region CustomAddedColors

  static const Color themeBlue = Color(0xff2680C5);
  static const Color themeBgColor = Color(0xffF8F8F8);
  static const Color themeEditOrange = Color(0xffE16D24);



  //endregion




  //region ShimmerColors
  static Color shimmerHighlightColor = const Color(0xfff2f2f2);
  static Color shimmerBaseColor = const Color(0xffb6b6b6);
  static Color shimmerContainerColor = const Color(0xffc2c2c2);
  //endregion
}