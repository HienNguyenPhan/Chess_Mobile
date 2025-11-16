import 'package:chess_app/core/dimens/app_dimen.dart';
import 'package:chess_app/core/dimens/dimens.dart';
import 'package:chess_app/core/style/app_text_style.dart';
import 'package:flutter/material.dart';

/// ✅ Field chỉ đọc (label bên trái, value bên phải)
class ReadOnlyField extends StatelessWidget {
  final String title;
  final String value;
  final TextAlign textAlign;

  const ReadOnlyField({
    super.key,
    required this.title,
    required this.value,
    this.textAlign = TextAlign.right,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: Dimens.d12.responsive(),
        horizontal: Dimens.d16.responsive(),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: AppTextStyles.style.s14.w400.grayColor),
          Expanded(
            child: Text(
              value,
              textAlign: textAlign,
              style: AppTextStyles.style.s16.w400.blackColor,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
