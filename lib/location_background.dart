import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class LocationBackground extends StatefulWidget {
  const LocationBackground({Key? key}) : super(key: key);

  @override
  _LocationBackgroundState createState() => _LocationBackgroundState();
}

class _LocationBackgroundState extends State<LocationBackground>
    with WidgetsBindingObserver {
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    //add an observer to monitor the widget lyfecycle changes
    WidgetsBinding.instance!.addObserver(this);

    // 訂閱位置更新事件
    // _positionStreamSubscription = Geolocator.getPositionStream(
    //         desiredAccuracy: LocationAccuracy.high,
    //         distanceFilter: 5,
    //         intervalDuration: const Duration(seconds: 5))
    //     .listen((position) {
    //   _showLocalNotification(position);
    // });
  }

  Future<void> _showLocalNotification(Position position) async {
    // const IOSNotificationDetails iOSPlatformChannelSpecifics =
    //     IOSNotificationDetails();
    // const NotificationDetails platformChannelSpecifics =
    //     NotificationDetails(iOS: iOSPlatformChannelSpecifics);

    // await flutterLocalNotificationsPlugin.show(
    //     0,
    //     'Location Update',
    //     'Latitude: ${position.latitude}, Longitude: ${position.longitude}',
    //     platformChannelSpecifics,
    //     payload: 'location_update');

    // Set up timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Taipei'));

    // Schedule local notification

    const IOSNotificationDetails iosNotificationDetails =
        IOSNotificationDetails();
    const NotificationDetails notificationDetails =
        NotificationDetails(iOS: iosNotificationDetails);
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Location Update',
        'Latitude: ${position.latitude}, Longitude: ${position.longitude}',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);

    // await flutterLocalNotificationsPlugin.periodicallyShow(
    //     0,
    //     'repeating title',
    //     'Latitude: ${position.latitude}, Longitude: ${position.longitude}',
    //     RepeatInterval.everyMinute,
    //     notificationDetails,
    //     androidAllowWhileIdle: true);

    SystemChannels.lifecycle.setMessageHandler((message) async {
      if (message!.contains('resumed') || message.contains('inactive')) {
        // Handle local notification when app is resumed or brought to foreground
        await flutterLocalNotificationsPlugin.cancelAll();
      }
      return null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    //don't forget to dispose of it when not needed anymore
    WidgetsBinding.instance!.removeObserver(this);
    // 取消訂閱位置更新事件
    _positionStreamSubscription?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed ||
        state == AppLifecycleState.inactive) {
      // 在此处添加需要执行的操作，当应用程序进入前台时将被调用
      _positionStreamSubscription?.cancel();
    } else {
      // 訂閱位置更新事件
      _positionStreamSubscription = Geolocator.getPositionStream(
              desiredAccuracy: LocationAccuracy.high,
              distanceFilter: 5,
              intervalDuration: const Duration(seconds: 5))
          .listen((position) {
        _showLocalNotification(position);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Background Location Tracking'),
      ),
      body: const Center(child: Text('Tracking location...')),
    );
  }
}
