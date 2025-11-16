import 'package:chess_app/core/custom_widgets/shimmer/shimmer_field.dart';
import 'package:chess_app/core/dimens/app_dimen.dart';
import 'package:chess_app/core/dimens/dimens.dart';
import 'package:chess_app/core/style/app_text_style.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String title;
  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final bool isLoading;

  const CustomTextField({
    super.key,
    required this.title,
    required this.hintText,
    required this.controller,
    this.keyboardType,
    this.onTap,
    this.readOnly = false,
    this.onChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: Dimens.d12.responsive(),
          horizontal: Dimens.d16.responsive(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTextStyles.style.s14.w400.grayColor),
            ShimmerField(width: Dimens.d120.responsive(),),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: Dimens.d12.responsive(),
        horizontal: Dimens.d16.responsive(),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: AppTextStyles.style.s14.w400.grayColor,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              onTap: onTap,
              onChanged: onChanged,
              readOnly: readOnly || onTap != null,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                isDense: true,
                hintText: hintText,
                hintStyle: AppTextStyles.style.s16.w300.grayColor,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: Dimens.d8.responsive(),
                  horizontal: Dimens.d8.responsive(),
                ),
              ),
              style: AppTextStyles.style.s16.w400.blackColor,
            ),
          ),
        ],
      ),
    );
  }
}
