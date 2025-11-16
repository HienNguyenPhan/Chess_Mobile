import 'package:chess_app/core/dimens/app_dimen.dart';
import 'package:chess_app/core/dimens/dimens.dart';
import 'package:chess_app/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTextStyles {
  static TextStyle style = GoogleFonts.beVietnamPro(
    fontSize: Dimens.d16.responsive(),
    fontWeight: FontWeight.w400,
    color: AppColors.black,
    // height: 1.2,
  );
}

extension AppFontWeight on TextStyle {
  /// FontWeight.w400
  TextStyle get w300 => copyWith(fontWeight: FontWeight.w300);

  /// FontWeight.w400
  TextStyle get w400 => copyWith(fontWeight: FontWeight.w400);

  /// FontWeight.w500
  TextStyle get w500 => copyWith(fontWeight: FontWeight.w500);

  /// FontWeight.w600
  TextStyle get w600 => copyWith(fontWeight: FontWeight.w600);

  /// FontWeight.w700
  TextStyle get w700 => copyWith(fontWeight: FontWeight.w700);

  /// FontWeight.w800
  TextStyle get w800 => copyWith(fontWeight: FontWeight.w800);

  /// FontWeight.w800
  TextStyle get w900 => copyWith(fontWeight: FontWeight.w900);

  // FontWeight.w800
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
}

extension AppFontSize on TextStyle {
  /// fontSize: 10
  TextStyle get s10 => copyWith(fontSize: Dimens.d10.responsive());

  /// fontSize: 11
  TextStyle get s11 => copyWith(fontSize: Dimens.d11.responsive());

  /// fontSize: 12
  TextStyle get s12 => copyWith(fontSize: Dimens.d12.responsive());

  /// fontSize: 13
  TextStyle get s13 => copyWith(fontSize: Dimens.d13.responsive());

  /// fontSize: 14
  TextStyle get s14 => copyWith(fontSize: Dimens.d14.responsive());

  /// fontSize: 15
  TextStyle get s15 => copyWith(fontSize: Dimens.d15.responsive());

  /// fontSize: 16
  TextStyle get s16 => copyWith(fontSize: Dimens.d16.responsive());

  /// fontSize: 17
  TextStyle get s17 => copyWith(fontSize: Dimens.d17.responsive());

  /// fontSize: 18
  TextStyle get s18 => copyWith(fontSize: Dimens.d18.responsive());

  /// fontSize: 19
  TextStyle get s19 => copyWith(fontSize: Dimens.d19.responsive());

  /// fontSize: 20
  TextStyle get s20 => copyWith(fontSize: Dimens.d20.responsive());

  /// fontSize: 22
  TextStyle get s22 => copyWith(fontSize: Dimens.d22.responsive());

  /// fontSize: 24
  TextStyle get s24 => copyWith(fontSize: Dimens.d24.responsive());

  /// fontSize: 25
  TextStyle get s25 => copyWith(fontSize: Dimens.d25.responsive());

  /// fontSize: 28
  TextStyle get s28 => copyWith(fontSize: Dimens.d28.responsive());

  /// fontSize: 32
  TextStyle get s32 => copyWith(fontSize: Dimens.d32.responsive());

  /// fontSize: s40
  TextStyle get s40 => copyWith(fontSize: Dimens.d40.responsive());

  /// fontSize: 90
  TextStyle get s90 => copyWith(fontSize: Dimens.d90.responsive());
}

extension AppFontColor on TextStyle {
  // Text Color
  TextStyle get whiteColor => copyWith(color: AppColors.white);

  TextStyle get blackColor => copyWith(color: AppColors.black);

  TextStyle get silverChaliceColor => copyWith(color: AppColors.silverChalice);

  TextStyle get radicalRedColor => copyWith(color: AppColors.radicalRed);

  TextStyle get springGreenColor => copyWith(color: AppColors.springGreen);

  TextStyle get woodSmokeColor => copyWith(color: AppColors.woodSmoke);

  TextStyle get grayColor => copyWith(color: AppColors.gray);

  TextStyle get silverColor => copyWith(color: AppColors.silver);

  TextStyle get dodgerBlueColor => copyWith(color: AppColors.dodgerBlue);

  TextStyle get silverMist => copyWith(color: AppColors.silverMist);

  TextStyle get broomColor=> copyWith(color: AppColors.broom);

  TextStyle get dustyGrayColor => copyWith(color: AppColors.dustyGray);

  TextStyle get gullGrayColor => copyWith(color: AppColors.gullGray);
}

extension AppFontStyle on TextStyle {
  // color: AppColors.white,
  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);
}

extension AppFontDecoration on TextStyle {
  // decoration: TextDecoration.overline,
  TextStyle get overline => copyWith(decoration: TextDecoration.overline);

  // decoration: TextDecoration.underline,
  TextStyle get underline => copyWith(decoration: TextDecoration.underline);
}
