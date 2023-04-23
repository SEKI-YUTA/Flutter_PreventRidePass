import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:prevent_ride_pass/location_list_screen.dart';
import 'package:prevent_ride_pass/map_screen.dart';
import 'package:prevent_ride_pass/setting_screen.dart';
import 'util/AppUtil.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyMapWidget(),
    );
  }
}

class MyMapWidget extends StatefulWidget {
  const MyMapWidget({super.key});

  @override
  State<MyMapWidget> createState() => _MyMapWidgetState();
}

class _MyMapWidgetState extends State<MyMapWidget> {
  static const _tabList = [MapScreen(), SettingScreen()];
  int _tabIndex = 0;
  bool _locationAddBtnShown = false;
  void _tabTapped(int index) {
    setState(() {
      _tabIndex = index;
    });
  }

  void _toggleLocationBtnShow(bool? state) {
    if (state != null) {
      _locationAddBtnShown = state!;
    } else {
      _locationAddBtnShown = !_locationAddBtnShown;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  Fluttertoast.showToast(msg: "位置を追加");
                  _toggleLocationBtnShow(null);
                  _tabIndex = 0;
                  setState(() {});
                },
                icon: const Icon(Icons.add)),
            IconButton(
                onPressed: () {
                  Fluttertoast.showToast(msg: "位置のリストを表示");
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LocationListScreen(),
                      ));
                },
                icon: const Icon(Icons.list))
          ],
        ),
        floatingActionButton: Visibility(
          visible: _locationAddBtnShown,
          child: FloatingActionButton(
            onPressed: () {
              if (_tabIndex == 0) {
                Fluttertoast.showToast(msg: "通知を出す処理");
                AppUtil.notify();
              } else {
                _tabIndex = 0;
                setState(() {});
              }
            },
            child: const Icon(Icons.send),
          ),
        ),
        bottomNavigationBar:
            BottomNavigationBar(onTap: _tabTapped, items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "地図"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "設定"),
        ]),
        body: IndexedStack(
          index: _tabIndex,
          children: _tabList,
        ));
  }
}
