import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    // Manejar la respuesta de la notificación aquí si es necesario
  }

static Future<void> initialize() async {
  const AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings("@mipmap/ic_launcher");

  const InitializationSettings initializationSettings = InitializationSettings(
    android: androidInitializationSettings,
  );

  // Crear el canal de notificación
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(const AndroidNotificationChannel(
    'channelId', // Debe coincidir con el ID usado en showNotification y showNotificationSchedule
    'Channel Name',
    description: 'Description of the channel',
    importance: Importance.high,
    playSound: true,
  ));

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    onDidReceiveBackgroundNotificationResponse: onDidReceiveNotificationResponse,
  );

  // Solicitar permisos para notificaciones
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
}

  static Future<void> showNotification(String title, String body) async {
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        'channelId', // Asegúrate de que este ID coincida
        'Channel Name',
        channelDescription: 'Description of the channel',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true, // Muestra la hora en que se envió la notificación
      ),
    );

    await flutterLocalNotificationsPlugin.show(0, title, body, platformChannelSpecifics);
  }

  static Future<void> showNotificationSchedule(
      String title, String body, DateTime scheduledDate) async {
    // Asegúrate de que scheduledDate sea una fecha futura
    if (scheduledDate.isBefore(DateTime.now())) {
      print("La fecha programada debe ser futura.");
      return;
    }

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        'channelId', // Asegúrate de que este ID coincida
        'Channel Name',
        channelDescription: 'Description of the channel',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      androidAllowWhileIdle: true, // Permitir notificaciones incluso en modo de reposo
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }
}
