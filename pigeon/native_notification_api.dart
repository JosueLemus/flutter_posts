import 'package:pigeon/pigeon.dart';

class NotificationPayload {
  final String title;
  final String body;

  NotificationPayload({required this.title, required this.body});
}

@HostApi()
abstract class NativeNotificationApi {
  void showNotification(NotificationPayload payload);
}
