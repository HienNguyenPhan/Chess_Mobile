import 'package:bot_toast/bot_toast.dart';
import 'package:chess_app/core/config/device_size_constants.dart';
import 'package:chess_app/core/config/size_config.dart';
import 'package:chess_app/core/dimens/app_dimen.dart';
import 'package:chess_app/core/routes/app_routes.dart';
import 'package:chess_app/core/theme/app_theme.dart';
import 'package:chess_app/features/settings/bloc/setting_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChessApp extends StatelessWidget {
  final bool isLoggedIn;
  const ChessApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    AppDimen.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ScreenUtilInit(
        designSize: const Size(
          DeviceSizeConstants.designDeviceWidth,
          DeviceSizeConstants.designDeviceHeight,
        ),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, __) {
          return BlocProvider.value(
            value: GetIt.I<SettingBloc>(),
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              theme: AppThemes.themeLight,
              builder: BotToastInit(),
              routerConfig: router,
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
            ),
          );
        },
      ),
    );
  }
}

