import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart';
import 'package:prevent_ride_pass/AppConstantValues.dart';
import 'package:prevent_ride_pass/LocationBloc.dart';
import 'package:prevent_ride_pass/location_event.dart';
import 'package:prevent_ride_pass/location_state.dart';
import 'package:prevent_ride_pass/location_list_screen.dart';
import 'package:prevent_ride_pass/map_screen.dart';
import 'package:prevent_ride_pass/model/SavedLocation.dart';
import 'package:prevent_ride_pass/setting_screen.dart';
import 'package:sqflite/sqflite.dart';
import "model/SavedLocation.dart";
import 'util/AppUtil.dart';

void main() {
  runApp(const MyApp());
  // https://github.com/red-star25/flutter_mapbox_blog
}

/**
 * app stateを作る
 * loadingevent loadedevent
 * repository
 * 
 */

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider<LocationBloc>(
      create: (_) => LocationBloc()..add(LoadAllLocation()),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MapAppRoot(),
      ),
    );
  }
}

class MapAppRoot extends StatefulWidget {
  const MapAppRoot({super.key});

  @override
  State<MapAppRoot> createState() => _MapAppRootState();
}

class _MapAppRootState extends State<MapAppRoot> {
  static const _tabList = [MapScreen(), SettingScreen()];
  int _tabIndex = 0;
  bool _locationAddBtnShown = false;
  List<SavedLocation> allLocations = List.empty();
  Database? database = null;

  @override
  void initState() {
    super.initState();
    initialize();
    // WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
    //   setState(() {});
    // });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> initialize() async {
    database = await AppUtil.openAppDatabase();
    allLocations = await AppUtil.getSavedLocations(database!);
    print("item length " + allLocations.length.toString());
  }

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
    print("build");
    // context
    //     .read<LocationBloc>()
    //     .add(AddLocationToAllLocation(SavedLocation("AAA", 35.9999, 135.7777)));
    // context.read<LocationBloc>().add(SetAllLocationEvent(allLocations));
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
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
                    Fluttertoast.showToast(msg: "位置を追加する処理");
                    // AppUtil.notify();
                    print(
                        "picked lat: ${state.pickedLocation?.latitude} lon: ${state.pickedLocation?.longitude}");
                    if (state.pickedLocation != null) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return addDialog(state.pickedLocation!,
                                (locationItem) async {
                              if (database != null) {
                                int id = await database!.insert(
                                    SavedLocation.tableName,
                                    locationItem.toMap(),
                                    conflictAlgorithm:
                                        ConflictAlgorithm.replace);
                                Navigator.pop(context, true);
                                context.read<LocationBloc>().add(
                                    AddLocationToAllLocation(locationItem));
                              }
                            });
                          });
                    }
                  } else {
                    _tabIndex = 0;
                    setState(() {});
                  }
                },
                child: const Icon(Icons.add),
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
                currentIndex: _tabIndex,
                onTap: _tabTapped,
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.map), label: "地図"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.settings), label: "設定"),
                ]),
            body: IndexedStack(
              index: _tabIndex,
              children: _tabList,
            ));
      },
    );
  }

  Dialog addDialog(LatLng location, void Function(SavedLocation) addLocation) {
    final SizedBox spacer1 = SizedBox(
      height: 8,
    );
    String inputedName = "";
    double latitude = 0.0;
    double longitude = 0.0;
    latitude = location.latitude;
    longitude = location.longitude;
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(10),
        height: 200,
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          TextField(
            onChanged: (value) {
              inputedName = value;
              setState(() {});
            },
            decoration: InputDecoration(hintText: "位置の名前"),
          ),
          spacer1,
          Text("緯度: ${location.latitude}\n経度: ${location.longitude}"),
          spacer1,
          ElevatedButton(
              onPressed: () {
                if (inputedName == "") {
                  Fluttertoast.showToast(msg: "名前が入力されていません");
                  return;
                }
                SavedLocation location =
                    SavedLocation(inputedName, latitude, longitude);
                addLocation(location);
              },
              child: Text("作成"))
        ]),
      ),
    );
  }
}
