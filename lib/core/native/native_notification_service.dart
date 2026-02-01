import 'native_notification_api.g.dart';

class NativeNotificationService {
  final NativeNotificationApi _api = NativeNotificationApi();

  void showLikeNotification({required String postTitle}) {
    _api.showNotification(
      NotificationPayload(title: 'Post liked', body: postTitle),
    );
  }
}
