import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
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
  int _tabIndex = 0;
  bool _locationAddBtnShown = false;
  bool _ableToAccessLocation = false;
  List<SavedLocation> allLocations = List.empty();
  Database? database = null;
  MapController mapController = MapController();
  // List<Widget> _tabList = [
  //   MapScreen(
  //     database: database,
  //   ),
  //   SettingScreen()
  // ];

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
    _ableToAccessLocation = await checkPermission();
    setState(() {});
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

  Future<bool> checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // そもそも位置情報サービスがオフになっている
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      } else if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        return true;
      }
    } else if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    } else {
      return false;
    }

    return permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse
        ? true
        : false;
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
                            builder: (context) => LocationListScreen(
                                mapController: mapController),
                          ));
                    },
                    icon: const Icon(Icons.list))
              ],
            ),
            // floatingActionButton: Visibility(
            //   visible: _locationAddBtnShown,
            //   child: FloatingActionButton(
            //     onPressed: () {
            //       if (_tabIndex == 0) {
            //         Fluttertoast.showToast(msg: "位置を追加する処理");
            //         // AppUtil.notify();
            //         print(
            //             "picked lat: ${state.pickedLocation?.latitude} lon: ${state.pickedLocation?.longitude}");
            //         if (state.pickedLocation != null) {
            //           showDialog(
            //               context: context,
            //               builder: (context) {
            //                 return addDialog(state.pickedLocation!,
            //                     (locationItem) async {
            //                   if (database != null) {
            //                     int id = await database!.insert(
            //                         SavedLocation.tableName,
            //                         locationItem.toMap(),
            //                         conflictAlgorithm:
            //                             ConflictAlgorithm.replace);
            //                     Navigator.pop(context, true);
            //                     context.read<LocationBloc>().add(
            //                         AddLocationToAllLocation(locationItem));
            //                   }
            //                 });
            //               });
            //         }
            //       } else {
            //         _tabIndex = 0;
            //         setState(() {});
            //       }
            //     },
            //     child: const Icon(Icons.add),
            //   ),
            // ),
            bottomNavigationBar: BottomNavigationBar(
                currentIndex: _tabIndex,
                onTap: _tabTapped,
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.map), label: "地図"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.settings), label: "設定"),
                ]),
            body: _ableToAccessLocation
                ? IndexedStack(
                    index: _tabIndex,
                    children: [
                      MapScreen(
                        database: database,
                        mapController: mapController,
                      ),
                      SettingScreen()
                    ],
                  )
                : Container());
      },
    );
  }
}
