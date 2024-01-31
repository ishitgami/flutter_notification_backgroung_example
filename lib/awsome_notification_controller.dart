import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationController {
  static ReceivedAction? initialAction;

  ///  *********************************************
  ///     INITIALIZATIONS
  ///  *********************************************
  ///
  static Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications().initialize(
        null, //'resource://drawable/res_app_icon',//
        [
          NotificationChannel(
              channelKey: 'scheduled_notification',
              channelName: 'Scheduled scheduled_notification',
              channelDescription: 'Channel for scheduled notifications',
              defaultColor: Colors.red,
              ledColor: Colors.red,
              playSound: true,
              soundSource: 'resource://raw/res_notification',
              importance: NotificationImportance.High,
              channelShowBadge: true,
              vibrationPattern: Int64List(2),
              ledOnMs: 1000,
              ledOffMs: 500,
              enableLights: true,
              enableVibration: true),
        ],
        debug: true);

    // Get initial notification action is optional
    initialAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: false);
  }

  static ReceivePort? receivePort;
  static Future<void> initializeIsolateReceivePort() async {
    receivePort = ReceivePort('Notification action port in main isolate')
      ..listen(
          (silentData) => onActionReceivedImplementationMethod(silentData));

    // This initialization only happens on main isolate
    IsolateNameServer.registerPortWithName(
        receivePort!.sendPort, 'notification_action_port');
  }

  ///  *********************************************
  ///     NOTIFICATION EVENTS LISTENER
  ///  *********************************************
  ///  Notifications events are only delivered after call this method
  static Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications()
        .setListeners(onActionReceivedMethod: onActionReceivedMethod);
  }

  ///  *********************************************
  ///     NOTIFICATION EVENTS
  ///  *********************************************
  ///
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.actionType == ActionType.SilentAction ||
        receivedAction.actionType == ActionType.SilentBackgroundAction) {
      // For background actions, you must hold the execution until the end
      print(
          'Message sent via notification input: "${receivedAction.buttonKeyPressed}"');

       await AwesomeNotifications().createNotification(
        schedule: NotificationInterval(
          interval: 5,
          repeats: false,
        ),
        content: NotificationContent(
          id: Random().nextInt(100),
          title: 'titlttttt',
          body: 'This is bodyyyyy',
          channelKey: 'scheduled_notification',
          displayOnBackground: true,
          displayOnForeground: true,
          notificationLayout: NotificationLayout.BigText,
          wakeUpScreen: true,
          customSound: 'resource://raw/res_notification',
        ),
        actionButtons: [
          NotificationActionButton(
              key: '30MIN',
              label: 'Remind in 30 min',
              actionType: ActionType.SilentAction),
          NotificationActionButton(
            key: '1HOUR',
            label: 'Remind in 1 hour',
          ),
        ],
      );
    } else {
      // this process is only necessary when you need to redirect the user
      // to a new page or use a valid context, since parallel isolates do not
      // have valid context, so you need redirect the execution to main isolate
      if (receivePort == null) {
        print(
            'onActionReceivedMethod was called inside a parallel dart isolate.');
        SendPort? sendPort =
            IsolateNameServer.lookupPortByName('notification_action_port');

        if (sendPort != null) {
          print('Redirecting the execution to main isolate process.');
          sendPort.send(receivedAction);
          return;
        }
      }

      return onActionReceivedImplementationMethod(receivedAction);
    }
  }

  static Future<void> onActionReceivedImplementationMethod(
      ReceivedAction receivedAction) async {}

  ///  *********************************************
  ///     NOTIFICATION CREATION METHODS
  ///  *********************************************
  ///
  static Future<void> createNewNotification({
    int? id,
    String? title,
    String? body,
    String? payload,
    String? period,
    int? day,
    int? month,
    int? year,
    int? hour,
    int? minute,
    int? second,
    Color? color,}
  ) async {
    //  DateTime now = DateTime.now().add(Duration(seconds: 8));
     await AwesomeNotifications().createNotification(
      // schedule: NotificationCalendar(
      //     day: now.day,
      //     hour: now.hour,
      //     minute: now.minute,
      //     second: now.second,
      //     millisecond: 1,
      //     repeats: false),
      content: NotificationContent(
        id: Random().nextInt(100),
        title: title,
        body: body,
        channelKey: 'scheduled_notification',
        displayOnBackground: true,
        displayOnForeground: true,
        notificationLayout: NotificationLayout.BigText,
        wakeUpScreen: true,
        customSound: 'resource://raw/res_notification',
      ),
      actionButtons: [
        NotificationActionButton(
            key: '30MIN',
            label: 'Remind in 30 min',
            actionType: ActionType.SilentAction,
            ),
        NotificationActionButton(
          key: '1HOUR',
          label: 'Remind in 1 hour',
          actionType: ActionType.SilentAction,
          
        ),
      ],
    );
  
  }
}
