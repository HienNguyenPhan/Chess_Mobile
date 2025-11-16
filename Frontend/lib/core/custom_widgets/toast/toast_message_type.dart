import 'package:chess_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';

enum ToastMessageType {
  success,
  error,
  normal,
}

extension ToastMessageTypeExtension on ToastMessageType {
  Color get backgroundColor {
    switch (this) {
      case ToastMessageType.success:
        return Colors.green;
      case ToastMessageType.error:
        return Colors.red;
      case ToastMessageType.normal:
        return Colors.grey;
    }
  }

  Widget get icon {
    switch (this) {
      case ToastMessageType.success:
        return Assets.svgs.icExclamationCircle.svg();
      case ToastMessageType.error:
        return Assets.svgs.icExclamationCircle.svg();
      case ToastMessageType.normal:
        return Assets.svgs.icExclamationCircle.svg();
    }
  }
}
