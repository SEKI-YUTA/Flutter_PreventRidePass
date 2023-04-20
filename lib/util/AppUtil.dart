import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AppUtil {
  static void demo() {
    print("demo");
  }

  static Future<void> notify() {
    final flnp = FlutterLocalNotificationsPlugin();
    return flnp
        .initialize(
          InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          ),
        )
        .then((_) => flnp.show(
            0,
            'title',
            'body',
            NotificationDetails(
              android: AndroidNotificationDetails(
                'channel_id',
                'channel_name',
              ),
            )));
  }
}
