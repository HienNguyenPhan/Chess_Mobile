import 'package:chess_app/core/config/size_config.dart';
import 'package:chess_app/core/dimens/app_dimen.dart';
import 'package:chess_app/core/dimens/dimens.dart';
import 'package:chess_app/core/style/app_text_style.dart';
import 'package:flutter/material.dart';

class GameModeCard extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const GameModeCard({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(Dimens.d16.responsive()),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(Dimens.d12.responsive()),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimens.d16.responsive()),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(image, width: Dimens.d48.responsive()),
            HorizontalSpacing(of: Dimens.d16.responsive()),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.style.s16.w700.blackColor),
                  VerticalSpacing(of: Dimens.d4.responsive()),
                  Text(subtitle, style: AppTextStyles.style.s13.grayColor),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF8E44AD),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
