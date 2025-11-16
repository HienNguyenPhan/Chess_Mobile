class Constants {
  const Constants._();

  // api request config
  static const Duration receiveTimeout = Duration(milliseconds: 15000);
  static const Duration connectionTimeout = Duration(milliseconds: 30000);

  // local storage key
  static const lsKeyAppConfig = 'lsKeyAppConfig';
  static const lsKeyIsShowOnboarding = 'lsKeyIsShowOnboarding';
  static const lsKeyAccessToken = 'lsKeyAccessToken';
  static const lsKeyLoggedUserInfo = 'lsKeyLoggedUserInfo';
  static const lsKeyConfigTheme = 'lsKeyConfigTheme';
  static const lsKeyNotificationSettings = 'lsKeyNotificationSettings';
}

enum EventBusType {
  expiredSession("expiredSession"),
  showLoading("showLoading"),
  hideLoading("hideLoading"),
  showMessage("showMessage"),
  reloadUnreadMessage("reloadUnreadMessage"),
  navigateToHome("navigateToHome");

  const EventBusType(this.value);
  final String value;
}
