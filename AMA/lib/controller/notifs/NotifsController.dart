import 'package:ama/controller/database/DatabaseController.dart';
import 'package:ama/controller/database/DatabaseMapper.dart';
import 'package:ama/model/Session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

class NotifsController {
    static NotifsController _instance;
    FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
    BuildContext _context;

    static NotifsController instance() {
      if (_instance == null) _instance = new NotifsController();

      return _instance;
    }

    NotifsController() {
      _flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    }


    init(BuildContext context) {
      this._context = context;
      var initializationSettingsAndroid = new AndroidInitializationSettings('amalogo');
      var initializationSettingsIOS = IOSInitializationSettings(onDidReceiveLocalNotification: _onDidReceiveLocalNotification);
      var initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
      _flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: _onSelectNotification);
    }

    Future _onSelectNotification(String payload) async {
      if (payload != null) {
        Navigator.pushNamed(this._context, '/sessionScreen', arguments: await DatabaseMapper.getSession(DatabaseController().getDatabase(), payload));
      }
    }

    Future _onDidReceiveLocalNotification(int id, String title, String body, String payload) async {
      if (payload != null) {
        Navigator.pushNamed(this._context, '/sessionScreen', arguments: await DatabaseMapper.getSession(DatabaseController().getDatabase(), payload));
      }
    }

    Future scheduleNotificationForSession(Session session) async {
      if (session.startTime.isBefore(DateTime.now()))
        return;

      var scheduledNotificationDateTime = session.startTime.subtract(new Duration(minutes: 10));
      print(new DateFormat.yMd().add_jm().format(scheduledNotificationDateTime));

      var androidPlatformChannelSpecifics =
      new AndroidNotificationDetails('channel id', 'channel name', 'channel description');
      var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
      NotificationDetails platformChannelSpecifics = new NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
      await _flutterLocalNotificationsPlugin.schedule(
          session.key.hashCode,
          'Get ready!',
          'Session "' + session.title + '", to be held at ' + session.location + ", will start in 10 minutes.",
          scheduledNotificationDateTime,
          platformChannelSpecifics,
          androidAllowWhileIdle: true, payload: session.key);
    }


    Future removeNotificationForSession(Session session) async {
      await _flutterLocalNotificationsPlugin.cancel(session.key.hashCode);
    }

}