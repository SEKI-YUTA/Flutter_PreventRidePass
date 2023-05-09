import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:prevent_ride_pass/AppConstantValues.dart';
import 'package:prevent_ride_pass/LocationBloc.dart';
import 'package:prevent_ride_pass/location_event.dart';
import 'package:prevent_ride_pass/location_state.dart';
import 'package:prevent_ride_pass/model/SavedLocation.dart';
import 'package:prevent_ride_pass/util/AppUtil.dart';
import 'package:sqflite/sqflite.dart';

class MapScreen extends StatefulWidget {
  MapScreen({super.key, required this.database, required this.mapController});
  Database? database;
  MapController mapController;
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.best,
  );
  late MapController mapController;
  Position? currentPos;
  List<Marker> markerList = List.empty(growable: true);
  late StreamSubscription<Position> positionStream;
  late LocationBloc _locationBloc;
  // bool isTracking = true;
  bool isStopped = false;
  bool isRinging = false;

  double _x = 10;
  double _y = 10;

  _MapScreenState() {
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      if (position != null) {
        updatePosition(position, _locationBloc);
      }
    });
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    mapController = widget.mapController;
    print("initState XXXX");
    _locationBloc = BlocProvider.of(context);
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print("state $state");

    switch (state) {
      case AppLifecycleState.paused:
        // ここに位置情報のlistenをフォアグラウンドサービスに移動させる処理を書く
        break;
      default:
        break;
    }
  }

  Future<Position> _determinePosition() async {
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child:
            currentPos == null ? const GettingPosWidget() : MapScreen(context));
  }

  Widget MapScreen(BuildContext context) {
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        // if (state.center != null && !state.isTracking) {
        // print("center is not null");
        // isTracking = false;
        // mapController.move(
        //     LatLng(state.center!.latitude, state.center!.longitude),
        //     mapController.zoom);
        // setState(() {});
        // }
        bool _locationPicked = state.pickedLocation != null ? true : false;
        return Stack(
          children: [
            FlutterMap(
              // keyを指定したら一応中心点は更新されるけど毎回のレンダリングが走ってしまう
              // key: Key('map${currentPos!.latitude}${currentPos!.longitude}'),
              mapController: mapController,
              options: MapOptions(
                  center: LatLng(currentPos!.latitude, currentPos!.longitude),
                  onPositionChanged: (position, hasGesture) {
                    if (!hasGesture) return;
                    context
                        .read<LocationBloc>()
                        .add(ToggleIsTrackingEvent(false));
                  },
                  onTap: (tapPosition, point) {
                    Fluttertoast.showToast(
                        msg: "lat: ${point.latitude} lon: ${point.longitude} ");
                    context
                        .read<LocationBloc>()
                        .add(SetPickedLocationEvent(point));
                    _addMarker(point);
                  },
                  interactiveFlags: InteractiveFlag.all,
                  enableScrollWheel: true,
                  scrollWheelVelocity: 0.00001),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                        point:
                            LatLng(currentPos!.latitude, currentPos!.longitude),
                        builder: (context) => const FlutterLogo()),
                    // Marker(
                    //     width: 60.0,
                    //     height: 60.0,
                    //     point:
                    //         LatLng(currentPos!.latitude, currentPos!.longitude),
                    //     builder: (context) => Container(
                    //           decoration: BoxDecoration(
                    //             color: Colors.blue.withOpacity(0.2),
                    //             borderRadius: BorderRadius.circular(30),
                    //           ),
                    //           child: IconButton(
                    //             icon: const Icon(Icons.accessibility,
                    //                 color: Colors.white),
                    //             onPressed: () {
                    //               print('Marker tapped!');
                    //             },
                    //           ),
                    //         )),
                    ...markerList,
                    state.center != null
                        ? Marker(
                            point: LatLng(state.center!.latitude,
                                state.center!.longitude),
                            builder: (context) => IconButton(
                                  icon: Icon(Icons.location_on_outlined),
                                  onPressed: () {},
                                ))
                        // 本来センターに値が入ってない時何も表示させたくない
                        : Marker(
                            point: LatLng(
                                currentPos!.latitude, currentPos!.longitude),
                            builder: (context) => const FlutterLogo()),
                    for (SavedLocation activeLocation
                        in state.activeLocatons) ...{
                      Marker(
                          point: LatLng(activeLocation.latitude,
                              activeLocation.longitude),
                          builder: (context) {
                            return IconButton(
                                onPressed: () {
                                  print(activeLocation.name);
                                },
                                icon: const Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                ));
                          })
                    }
                  ],
                ),
              ],
            ),
            Positioned(
                child: ElevatedButton(
              child: Text("Debug"),
              onPressed: () {
                // isTracking = true;
                positionStream.resume();
                setState(() {});
                print(mapController.zoom);
                context.read<LocationBloc>().add(ToggleIsTrackingEvent(true));
                print("XX ${state.isTracking}");
                mapController.move(
                    LatLng(currentPos!.latitude, currentPos!.longitude),
                    mapController.zoom);
              },
            )),
            Positioned(
                bottom: 10,
                child: ElevatedButton(
                  child: Text("Picked"),
                  onPressed: () {
                    // isTracking = true;
                    print(state.pickedLocation);
                  },
                )),
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: () => _locationPicked
                    ? _showAddDialog(state)
                    : Fluttertoast.showToast(msg: "位置が指定されていません。"),
                backgroundColor: _locationPicked ? Colors.blue : Colors.grey,
                child: const Icon(Icons.add),
              ),
            ),
            Positioned(
              left: _x,
              top: _y,
              child: GestureDetector(
                onPanUpdate: (details) {
                  _x += details.delta.dx;
                  _y += details.delta.dy;
                  setState(() {});
                },
                child: Container(
                  height: 160,
                  width: 160,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: SingleChildScrollView(
                      child: Column(
                          children: state.activeLocatons.map((item) {
                    return Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          child: Text(
                            item.name,
                            style: AppConstantValues.s_text,
                          ),
                        ),
                        Divider(
                          height: 4,
                          indent: 4,
                          endIndent: 4,
                        )
                      ],
                    );
                  }).toList())),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  void _addMarker(LatLng markerPos) {
    Marker marker = Marker(
        key: GlobalKey(
            debugLabel: "${markerPos.latitude}${markerPos.longitude}"),
        point: markerPos,
        builder: (context) => Container(
              child: IconButton(
                icon: const Icon(Icons.location_on),
                onPressed: () {
                  print("pressed");
                  for (int i = 0; i < markerList.length; i++) {
                    Marker m = markerList[i];
                    if (m.point == markerPos) {
                      print("equals");
                      markerList.remove(m);
                      setState(() {});

                      context
                          .read<LocationBloc>()
                          .add(ResetPickedLocationEvent());
                    }
                  }
                },
              ),
            ));
    markerList.add(marker);
    setState(() {});
  }

  void _showAddDialog(LocationState state) {
    Fluttertoast.showToast(msg: "位置を追加する処理");
    // AppUtil.notify();
    print(
        "picked lat: ${state.pickedLocation?.latitude} lon: ${state.pickedLocation?.longitude}");
    if (state.pickedLocation != null) {
      showDialog(
          context: context,
          builder: (context) {
            return addDialog(state.pickedLocation!, (locationItem) async {
              if (widget.database != null) {
                int id = await widget.database!.insert(
                    SavedLocation.tableName, locationItem.toMap(),
                    conflictAlgorithm: ConflictAlgorithm.replace);
                context
                    .read<LocationBloc>()
                    .add(AddLocationToAllLocation(locationItem));
              }
            });
          });
    }
  }

  /**
   * 位置情報をlistenしてる時に実行される
   */
  void updatePosition(Position position, LocationBloc bloc) {
    print(position == null
        ? 'Unknown'
        : 'update ${position.latitude.toString()}, ${position.longitude.toString()}');
    // print(isTracking ? "tracking" : "not tracking");
    if (position != null) {
      print("update currentPos");
      currentPos = position;
      // mapController.move(centerLatLng!, mapController.zoom);
      setState(() {});
    }

    if (mapController == null) {
      print("mapController is not itialized");
    } else {
      print(_locationBloc.state.isTracking);
      if (_locationBloc.state.isTracking) {
        print("mapController.move");
        Timer(const Duration(milliseconds: 100), () {
          mapController.move(
              LatLng(currentPos!.latitude, currentPos!.longitude), 16);
        });
      }
    }

    if (_locationBloc.state.activeLocatons?.length != 0) {
      // アクティブな位置がなければこれ以上処理をする必要がないのでreturn
      List<SavedLocation>? targetList = _locationBloc.state.activeLocatons;
      if (targetList == null) return;
      for (int i = 0; i < targetList.length; i++) {
        SavedLocation item = targetList[i];
        double distance = Geolocator.distanceBetween(currentPos!.latitude,
            currentPos!.longitude, item.latitude, item.longitude);
        print("distance $i: $distance");
        if (distance <= 300 && (!isRinging && !isStopped)) {
          AppUtil.notify(
              title: "通知",
              body: "目的地に近づきました。",
              id: AppUtil.STABLE_NOTIFICATION_ID);
          isRinging = true;
          setState(() {});
        }
      }
      return;
    }
  }

  Widget addDialog(LatLng location, void Function(SavedLocation) addLocation) {
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
                Navigator.pop(context);
              },
              child: Text("作成"))
        ]),
      ),
    );
  }
}

class GettingPosWidget extends StatelessWidget {
  const GettingPosWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text("位置情報取得中...")
        ],
      ),
    );
  }
}
