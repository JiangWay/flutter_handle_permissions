import 'package:flutter/material.dart';
import 'package:flutter_handle_permissions/location_background.dart';
import 'package:flutter_handle_permissions/permissions_location.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsList extends StatefulWidget {
  const PermissionsList({Key? key}) : super(key: key);

  @override
  _PermissionsListState createState() => _PermissionsListState();
}

class _PermissionsListState extends State<PermissionsList>
    with WidgetsBindingObserver {
  PermissionStatus _bluetoothStatus = PermissionStatus.denied;
  PermissionStatus _notificationStatus = PermissionStatus.denied;
  PermissionStatus _locationStatus = PermissionStatus.denied;
  PermissionStatus _sensorsStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    //add an observer to monitor the widget lyfecycle changes
    WidgetsBinding.instance!.addObserver(this);
    _checkBluetoothPermission();
    _checkNotificationEnabled();
    _checkLocationEnabled();
    _checkSensorsEnabled();
  }

  @override
  void dispose() {
    //don't forget to dispose of it when not needed anymore
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // 在此处添加需要执行的操作，当应用程序进入前台时将被调用
      // 更新狀態
      // print("I'm back");
      // 藍芽
      _checkBluetoothPermission();
      // 推播
      _checkNotificationEnabled();
      // 定位
      _checkLocationEnabled();
      // 移動
      _checkSensorsEnabled();
    }
  }

  Future<void> _checkBluetoothPermission() async {
    final status = await Permission.bluetooth.request();
    setState(() {
      _bluetoothStatus = status;
    });
  }

  Future<void> _checkNotificationEnabled() async {
    final status = await Permission.notification.request();
    setState(() {
      _notificationStatus = status;
    });
  }

  Future<void> _checkLocationEnabled() async {
    // location,
    // locationAlways,
    // locationWhenInUse,

    // You can request multiple permissions at once.
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.locationAlways,
      Permission.locationWhenInUse,
    ].request();
    print(Permission.location.toString() +
        " : " +
        statuses[Permission.location].toString());
    print(Permission.locationAlways.toString() +
        " : " +
        statuses[Permission.locationAlways].toString());
    print(Permission.locationWhenInUse.toString() +
        " : " +
        statuses[Permission.locationWhenInUse].toString());

    final status = await Permission.location.request();
    setState(() {
      _locationStatus = status;
    });
  }

  Future<void> _checkSensorsEnabled() async {
    final status = await Permission.sensors.request();
    setState(() {
      _sensorsStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permissions'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Bluetooth'),
            trailing: Text(_bluetoothStatus.toString()),
            onTap: () async {
              if (_bluetoothStatus.isGranted) {
                // await Permission.bluetooth.request();
                // _checkBluetoothPermission();
              } else {
                openAppSettings();
              }
            },
          ),
          ListTile(
            title: const Text('Push Notifications'),
            trailing: Text(_notificationStatus.toString()),
            onTap: () async {
              if (!_notificationStatus.isGranted) {
                openAppSettings();
              }
            },
          ),
          ListTile(
            title: const Text('Sensors'),
            trailing: Text(_sensorsStatus.toString()),
            onTap: () async {
              if (!_sensorsStatus.isGranted) {
                openAppSettings();
              }
            },
          ),
          ListTile(
            title: Text(Permission.location.toString()),
            trailing: Text(_locationStatus.toString()),
            onTap: () async {
              if (!_locationStatus.isGranted) {
                openAppSettings();
              }
            },
          ),
          ListTile(
              title: const Text("Location 詳情"),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PermissionsLocation()),
                );
              }),
          ListTile(
              title: const Text("Location 背景模式"),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LocationBackground()),
                );
              }),
        ],
      ),
    );
  }
}
