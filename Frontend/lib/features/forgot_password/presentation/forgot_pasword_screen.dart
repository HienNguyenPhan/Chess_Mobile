import 'package:chess_app/core/config/size_config.dart';
import 'package:chess_app/core/dimens/app_dimen.dart';
import 'package:chess_app/core/dimens/dimens.dart';
import 'package:chess_app/core/style/app_text_style.dart';
import 'package:chess_app/core/custom_widgets/toast/toast_message_type.dart';
import 'package:chess_app/core/custom_widgets/toast/toast_showable.dart';
import 'package:chess_app/core/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'bloc/forgot_password_bloc.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
      listener: (context, state) {
        if (state.status == ForgotPasswordStatus.failure) {
          ToastShowAble.show(
            toastType: ToastMessageType.error,
            message: state.errorMessage ?? 'Đã có lỗi xảy ra',
          );
        } else if (state.status == ForgotPasswordStatus.success) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text(
                'Thông báo',
                style: AppTextStyles.style.s20.w600.blackColor,
              ),
              content: Text(
                'Chúng tôi đã gửi liên kết đặt lại mật khẩu đến email của bạn.',
                style: AppTextStyles.style.s14.w400.blackColor,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    context.pop();  // Close dialog
                    context.go(RouteConstants.signin);  // Navigate to sign in
                  },
                  child: Text(
                    'Đã hiểu',
                    style: AppTextStyles.style.s14.w600.copyWith(
                      color: const Color(0xFF2F6C5A),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Quên mật khẩu',
              style: AppTextStyles.style.s20.w600.blackColor,
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  VerticalSpacing(of: Dimens.d24.responsive()),
                  Text(
                    'Nhập email bạn đã dùng để đăng ký, chúng tôi sẽ gửi đường dẫn đặt lại mật khẩu.',
                    style: AppTextStyles.style.s14.w400.blackColor,
                    textAlign: TextAlign.center,
                  ),
                  VerticalSpacing(of: Dimens.d24.responsive()),
                  TextField(
                    onChanged: (value) {
                      context.read<ForgotPasswordBloc>().add(EmailChanged(value));
                    },
                    style: AppTextStyles.style.s14.w400.blackColor,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: AppTextStyles.style.s14.w500.grayColor,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimens.d12.responsive()),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimens.d12.responsive()),
                        borderSide: const BorderSide(
                          color: Color(0xFF2F6C5A),
                          width: 1.5,
                        ),
                      ),
                      contentPadding: EdgeInsets.all(Dimens.d12.responsive()),
                    ),
                  ),
                  VerticalSpacing(of: Dimens.d24.responsive()),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.status == ForgotPasswordStatus.loading
                          ? null
                          : () {
                              context
                                  .read<ForgotPasswordBloc>()
                                  .add(const SubmitResetPassword());
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F6C5A),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: Dimens.d14.responsive(),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Dimens.d12.responsive()),
                        ),
                      ),
                      child: state.status == ForgotPasswordStatus.loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Gửi yêu cầu',
                              style: AppTextStyles.style.s16.w600.whiteColor,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
