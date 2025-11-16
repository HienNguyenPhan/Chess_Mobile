import 'package:bot_toast/bot_toast.dart';
import 'package:chess_app/core/config/size_config.dart';
import 'package:chess_app/core/custom_widgets/button/cupertino_button_custom.dart';
import 'package:chess_app/core/dimens/app_dimen.dart';
import 'package:chess_app/core/dimens/dimens.dart';
import 'package:chess_app/core/style/app_text_style.dart';
import 'package:chess_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'toast_message_type.dart';

mixin ToastShowAble {
  static void show({
    ToastMessageType toastType = ToastMessageType.error,
    required String message,
    int durationMilliseconds = 3000,
  }) {
    BotToast.cleanAll();
    late CancelFunc cancel;

    cancel = BotToast.showCustomNotification(
      animationDuration: const Duration(milliseconds: 300),
      animationReverseDuration: const Duration(milliseconds: 300),
      duration: Duration(milliseconds: durationMilliseconds),
      backButtonBehavior: BackButtonBehavior.close,
      toastBuilder: (_) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: Dimens.d20.responsive()),
          padding: EdgeInsets.all(Dimens.d12.responsive()),
          decoration: BoxDecoration(
            color: toastType.backgroundColor,
            borderRadius: BorderRadius.circular(Dimens.d10.responsive()),
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    toastType.icon,
                    HorizontalSpacing(of: Dimens.d8.responsive()),
                    Flexible(
                      child: Text(
                        message,
                        style: AppTextStyles.style.s14.w400.whiteColor,
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoButtonCustom(
                onPressed: () {
                  cancel();
                },
                child: Container(
                  padding: EdgeInsets.all(Dimens.d4.responsive()),
                  child: Assets.svgs.icCloseSimple.svg(
                    width: Dimens.d8.responsive(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      enableSlideOff: true,
      onlyOne: true,
      crossPage: true,
      useSafeArea: true,
    );
  }

  // static void showConfirm({
  //   required String message,
  //   String title = 'Message',
  //   bool clickClose = true,
  //   String? titleBtn,
  //   Function()? onPressed,
  // }) {
  //   BotToast.showAnimationWidget(
  //     clickClose: clickClose,
  //     allowClick: false,
  //     onlyOne: true,
  //     crossPage: true,
  //     backButtonBehavior: BackButtonBehavior.none,
  //     backgroundColor: AppColors.black.withOpacity(0.4),
  //     toastBuilder: (cancelFunc) {
  //       return AlertDialog(
  //         backgroundColor: Colors.white,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(
  //             Dimens.d12.responsive(),
  //           ),
  //         ),
  //         titleTextStyle: AppTextStyles.style.s20.w700.blackColor,
  //         contentTextStyle: AppTextStyles.style.s14.blackColor,
  //         title: Text(
  //           title,
  //           style: AppTextStyles.style.s15.bold.secondaryColor,
  //         ),
  //         content: Text(
  //           message,
  //           style: AppTextStyles.style.s13,
  //         ),
  //         actionsPadding: EdgeInsets.zero,
  //         actions: onPressed != null
  //             ? [
  //                 SizedBox(
  //                   width: double.infinity,
  //                   height: Dimens.d48.responsive(),
  //                   child: RawMaterialButton(
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.only(
  //                         bottomLeft: Radius.circular(
  //                           Dimens.d12.responsive(),
  //                         ),
  //                         bottomRight: Radius.circular(
  //                           Dimens.d12.responsive(),
  //                         ),
  //                       ),
  //                     ),
  //                     onPressed: () {
  //                       onPressed();
  //                       BotToast.cleanAll();
  //                     },
  //                     elevation: 0,
  //                     hoverElevation: 0,
  //                     focusElevation: 0,
  //                     highlightElevation: 0,
  //                     fillColor: AppColors.lightGray,
  //                     child: Text(
  //                       titleBtn ?? 'close'.tr(),
  //                       style: AppTextStyles.style.s15,
  //                     ),
  //                   ),
  //                 ),
  //               ]
  //             : null,
  //       );
  //     },
  //     animationDuration: const Duration(milliseconds: 300),
  //   );
  // }

  // static void showToastCenter({
  //   required String message,
  //   int seconds = 3,
  // }) {
  //   BotToast.cleanAll();
  //   BotToast.showCustomNotification(
  //     animationDuration: const Duration(milliseconds: 300),
  //     animationReverseDuration: const Duration(milliseconds: 300),
  //     duration: Duration(seconds: seconds),
  //     backButtonBehavior: BackButtonBehavior.ignore,
  //     align: Alignment.center,
  //     toastBuilder: (_) {
  //       return GestureDetector(
  //         onTap: () {
  //           BotToast.cleanAll();
  //         },
  //         child: Container(
  //           padding: EdgeInsets.symmetric(
  //             vertical: Dimens.d15.responsive(),
  //             horizontal: Dimens.d35.responsive(),
  //           ),
  //           decoration: BoxDecoration(
  //             color: AppColors.scorpion,
  //             border: Border.all(
  //               color: AppColors.dimGray,
  //             ),
  //             borderRadius: BorderRadius.circular(
  //               Dimens.d13.responsive(),
  //             ),
  //           ),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Text(
  //                 message,
  //                 style: AppTextStyles.style.s14.w700.whiteColor,
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //     enableSlideOff: true,
  //     onlyOne: true,
  //     crossPage: true,
  //     useSafeArea: true,
  //   );
  // }
}
