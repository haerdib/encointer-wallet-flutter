import 'package:collection/collection.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:encointer_wallet/service/meetup/feed_model.dart';
import 'package:encointer_wallet/service/meetup/feed_repo.dart';
import 'package:encointer_wallet/service/notification/lib/notification.dart';

class NotificationHandler {
  static Future<void> fetchMessagesAndScheduleNotifications(
    tz.Location local,
    ScheduleNotification scheduleNotification,
    String langCode,
  ) async {
    final feeds = await FeedRepo().fetchData(langCode);
    if (feeds != null && feeds.isNotEmpty) await _registerScheduleNotifications(feeds, local, scheduleNotification);
  }

  static Future<void> _registerScheduleNotifications(
    List<Feed> feeds,
    tz.Location local,
    ScheduleNotification scheduleNotification,
  ) async {
    feeds.forEachIndexed((i, e) async {
      if (tz.TZDateTime.from(feeds[i].showAt, local).isAfter(DateTime.now())) {
        await scheduleNotification(
          feeds[i].notificationId,
          feeds[i].title,
          feeds[i].content,
          tz.TZDateTime.from(feeds[i].showAt, local),
        );
      }
    });
  }
}
