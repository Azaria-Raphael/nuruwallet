import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      const InitializationSettings(android: android),
    );

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl == null) return;

    await androidImpl.requestNotificationsPermission();

    await androidImpl.createNotificationChannel(
      const AndroidNotificationChannel(
        'budget_alerts',
        'Budget Alerts',
        description: 'Alerts when you are near or over a category budget',
        importance: Importance.high,
      ),
    );
    await androidImpl.createNotificationChannel(
      const AndroidNotificationChannel(
        'reminders',
        'Daily Reminders',
        description: 'Daily prompt to log your finances',
        importance: Importance.defaultImportance,
      ),
    );
    await androidImpl.createNotificationChannel(
      const AndroidNotificationChannel(
        'goal_alerts',
        'Goal Alerts',
        description: 'Alerts for upcoming savings goal deadlines',
        importance: Importance.high,
      ),
    );
  }

  static Future<void> showBudgetAlert({
    required String categoryName,
    required double spent,
    required double limit,
  }) async {
    final percent = (spent / limit * 100).round();
    final id = categoryName.hashCode & 0x7FFFFFFF;
    await _plugin.show(
      id,
      'Budget Alert: $categoryName',
      "You've used $percent% of your $categoryName budget "
          "(TZS ${limit.toStringAsFixed(0)}).",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_alerts',
          'Budget Alerts',
          channelDescription:
              'Alerts when you are near or over a category budget',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  static Future<void> showGoalDeadlineAlert({
    required String goalName,
    required int daysLeft,
    required String goalId,
  }) async {
    final id = goalId.hashCode & 0x7FFFFFFF;
    final title = daysLeft <= 0 ? 'Goal Deadline Passed' : 'Goal Deadline Soon';
    final body = daysLeft <= 0
        ? '$goalName deadline has passed — keep saving!'
        : '$goalName is due in $daysLeft ${daysLeft == 1 ? "day" : "days"}.';
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'goal_alerts',
          'Goal Alerts',
          channelDescription: 'Alerts for upcoming savings goal deadlines',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  static Future<void> showDailyReminderIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    if (prefs.getString('last_daily_reminder') == todayKey) return;

    await prefs.setString('last_daily_reminder', todayKey);
    await _plugin.show(
      1,
      "Don't forget to log today's expenses",
      'Keep your finances clear — open NuruWallet and record your transactions.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders',
          'Daily Reminders',
          channelDescription: 'Daily prompt to log your finances',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
    );
  }
}
