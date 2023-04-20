import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PermissionsLocation extends StatefulWidget {
  const PermissionsLocation({Key? key}) : super(key: key);

  @override
  _PermissionsLocationState createState() => _PermissionsLocationState();
}

class _PermissionsLocationState extends State<PermissionsLocation>
    with WidgetsBindingObserver {
  List<dynamic> _positionInfoList = [];
  LocationAccuracyStatus _locationAccuracy = LocationAccuracyStatus.unknown;

  @override
  void initState() {
    super.initState();
    //add an observer to monitor the widget lyfecycle changes
    WidgetsBinding.instance!.addObserver(this);

    //這邊寫下初始設定
    _checkLocationAccuracy();
    _getHighLocationAccuracy();
    _checkFineLocationEnabled();
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
    }
  }

  Future<void> _checkLocationAccuracy() async {
    var accuracy = await Geolocator.getLocationAccuracy();
    setState(() {
      _locationAccuracy = accuracy;
    });
  }

  Future<void> _getHighLocationAccuracy() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    Map<String, dynamic> positionMap = position.toJson();
    positionMap.forEach((k, v) => print('${k}: ${v}'));
    List<MapEntry<String, dynamic>> positionMapToList =
        positionMap.entries.toList();

    setState(() {
      _positionInfoList = positionMapToList;
    });
  }

  Future<bool> _checkFineLocationEnabled() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      // 如果设备上的精确定位服务永久禁用，则无法访问位置。
      // 这种情况通常是由用户在系统设置中手动禁用位置服务造成的。
      // 可以考虑向用户提供帮助文档或引导用户启用精确定位服务。
      return false;
    } else if (permission == LocationPermission.denied) {
      // 如果设备上的精确定位服务已被禁用，则需要请求权限。
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // 用户拒绝了精确定位权限请求，无法访问位置。
        return false;
      }
    }

    // 检查设备上的精确定位服务是否已启用。
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('_getHighLocationAccuracy'),
            trailing: const Icon(Icons.location_on),
            onTap: () async {
              _getHighLocationAccuracy();
            },
          ),
          ListTile(
            title: const Text('使用精確位置'),
            trailing: Text(_locationAccuracy.toString()),
          ),
          ..._positionInfoList
              .map((item) => ListTile(
                  title: Text(item.key), trailing: Text(item.value.toString())))
              .toList()
        ],
      ),
    );
  }
}
