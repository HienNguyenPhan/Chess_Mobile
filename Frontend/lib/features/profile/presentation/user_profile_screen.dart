import 'package:chess_app/core/config/size_config.dart';
import 'package:chess_app/core/custom_widgets/textfield/custom_datetime_field.dart';
import 'package:chess_app/core/custom_widgets/textfield/custom_textfield.dart';
import 'package:chess_app/core/custom_widgets/textfield/read_only_field.dart';
import 'package:chess_app/core/custom_widgets/toast/toast_message_type.dart';
import 'package:chess_app/core/custom_widgets/toast/toast_showable.dart';
import 'package:chess_app/core/data/enum/status_enum.dart';
import 'package:chess_app/core/dimens/app_dimen.dart';
import 'package:chess_app/core/dimens/dimens.dart';
import 'package:chess_app/core/style/app_text_style.dart';
import 'package:chess_app/features/profile/presentation/bloc/user_profile_bloc.dart';
import 'package:chess_app/gen/assets.gen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final userNameController = TextEditingController();
  final phoneController = TextEditingController();
  final birthDayController = TextEditingController();

  @override
  void initState() {
    super.initState();
    userNameController.text = user?.displayName ?? '';
    // Demo data
    phoneController.text = '+84 123456789';
    birthDayController.text = '01/01/2000';
    context.read<UserProfileBloc>().add(LoadUserProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    AppDimen.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimens.d20.responsive()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VerticalSpacing(of: Dimens.d20.responsive()),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  Text(
                    'personal_info'.tr(),
                    style: AppTextStyles.style.s18.w600.blackColor,
                  ),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),
              VerticalSpacing(of: Dimens.d20.responsive()),
              Expanded(
                child: SingleChildScrollView(
                  child: BlocConsumer<UserProfileBloc, UserProfileState>(
                    listener: (context, state) {
                      userNameController.text = state.name;
                      phoneController.text = state.phone;
                      birthDayController.text = state.birthDay;
                      if (state.saved) {
                        ToastShowAble.show(
                          message: 'save_info'.tr(),
                          toastType: ToastMessageType.success,
                        );
                        context.pop();
                      }
                    },
                    builder: (context, state) {
                      return Column(
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: Dimens.d40.responsive(),
                              backgroundColor: Colors.grey.shade200,
                              child: Assets.svgs.chessLogo.svg(
                                width: Dimens.d44.responsive(),
                              ),
                            ),
                          ),
                          VerticalSpacing(of: Dimens.d12.responsive()),
                          Center(
                            child: Text(
                              user?.displayName ?? 'player'.tr(),
                              style: AppTextStyles.style.s18.w600.blackColor,
                            ),
                          ),
                          VerticalSpacing(of: Dimens.d20.responsive()),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(
                                Dimens.d12.responsive(),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                CustomTextField(
                                  title: 'name'.tr(),
                                  controller: userNameController,
                                  hintText: 'tap_here_to_enter_name'.tr(),
                                  keyboardType: TextInputType.name,
                                  onChanged: (value) {
                                    context.read<UserProfileBloc>().add(
                                      UpdateUserFieldEvent(name: value),
                                    );
                                  },
                                  isLoading: state
                                      .status
                                      .isInProgress,
                                ),
                                _divider(),
                                CustomTextField(
                                  title: 'phone_number'.tr(),
                                  controller: phoneController,
                                  hintText: '+84 123456789',
                                  keyboardType: TextInputType.phone,
                                  onChanged: (value) {
                                    context.read<UserProfileBloc>().add(
                                      UpdateUserFieldEvent(phone: value),
                                    );
                                  },
                                  isLoading: state.status.isInProgress,
                                ),
                                _divider(),
                                ReadOnlyField(
                                  title: 'email'.tr(),
                                  value: user?.email ?? 'no_email'.tr(),
                                ),
                                _divider(),
                                CustomDateTimeField(
                                  title: 'birth_day'.tr(),
                                  hintText: 'tap_here_to_choose_date'.tr(),
                                  controller: birthDayController,
                                  onDateSelected: (date) {
                                    context.read<UserProfileBloc>().add(
                                      UpdateUserFieldEvent(birthDay: date),
                                    );
                                  },
                                  isLoading: state.status.isInProgress,
                                ),
                              ],
                            ),
                          ),
                          VerticalSpacing(of: Dimens.d40.responsive()),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<UserProfileBloc>().add(
                                  SaveUserProfileEvent(),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2F6C5A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'save_info'.tr(),
                                style: AppTextStyles.style.s16.w600.whiteColor,
                              ),
                            ),
                          ),
                          VerticalSpacing(of: Dimens.d20.responsive()),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() =>
      Divider(color: Colors.grey.shade300, thickness: 1, height: 1);
}
