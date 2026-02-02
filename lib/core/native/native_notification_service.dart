import 'native_notification_api.g.dart';

class NativeNotificationService {
  final NativeNotificationApi _api = NativeNotificationApi();

  void showLikeNotification({required String postTitle, required String body}) {
    _api.showNotification(
      NotificationPayload(title: 'Te ha gustado: $postTitle', body: body),
    );
  }
}
