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
import 'package:prevent_ride_pass/LocationBloc.dart';
import 'package:prevent_ride_pass/location_event.dart';
import 'package:prevent_ride_pass/location_state.dart';
import 'package:prevent_ride_pass/util/AppUtil.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.best,
  );
  static MapController mapController = MapController();
  Position? currentPos;
  List<Marker> markerList = [];
  late StreamSubscription<Position> positionStream;
  late LocationBloc _locationBloc;
  bool isTracking = true;
  _MapScreenState() {
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      if (position != null) {
        updatePosition(position);
      }
    });
  }
  @override
  void initState() {
    super.initState();
    print("initState");
    // initialize();
    _locationBloc = BlocProvider.of(context);
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    print("dispose");
  }

  Future<Position> _determinePosition() async {
    return await Geolocator.getCurrentPosition();
  }

  // Future<void> initialize() async {
  //   currentPos = await _determinePosition();
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return Center(
        child:
            currentPos == null ? const GettingPosWidget() : MapScreen(context));
  }

  Widget MapScreen(BuildContext context) {
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        if (state.center != null && !state.isTracking) {
          // print("center is not null");
          isTracking = false;
          positionStream.pause();
          mapController.move(
              LatLng(state.center!.latitude, state.center!.longitude),
              mapController.zoom);
          // setState(() {});
        }
        return Stack(
          children: [
            FlutterMap(
              // keyを指定したら一応中心点は更新されるけど毎回のレンダリングが走ってしまう
              // key: Key('map${currentPos!.latitude}${currentPos!.longitude}'),
              mapController: mapController,
              options: MapOptions(
                  keepAlive: true,
                  // center: LatLng(34.70781811178657, 135.64362330253846),
                  center: LatLng(currentPos!.latitude, currentPos!.longitude),
                  onTap: (tapPosition, point) {
                    Fluttertoast.showToast(
                        msg: "lat: ${point.latitude} lon: ${point.longitude} ");
                    context
                        .read<LocationBloc>()
                        .add(SetPickedLocationEvent(point));
                    addMarker(point);
                  },
                  // center: centerLatLng,
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
                    Marker(
                        width: 60.0,
                        height: 60.0,
                        point:
                            LatLng(currentPos!.latitude, currentPos!.longitude),
                        builder: (context) => Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.accessibility,
                                    color: Colors.white),
                                onPressed: () {
                                  print('Marker tapped!');
                                },
                              ),
                            )),
                    ...markerList,
                    state.center != null && !isTracking
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
                    Marker(
                        point:
                            LatLng(currentPos!.latitude, currentPos!.longitude),
                        builder: (context) => const FlutterLogo())
                  ],
                ),
              ],
            ),
            Positioned(
                child: ElevatedButton(
              child: Text("Debug"),
              onPressed: () {
                isTracking = true;
                positionStream.resume();
                setState(() {});
                print(mapController.zoom);
                context.read<LocationBloc>().add(ToggleIsTrackingEvent(true));
                mapController.move(
                    LatLng(currentPos!.latitude, currentPos!.longitude),
                    mapController.zoom);
              },
            ))
          ],
        );
      },
    );
  }

  void addMarker(LatLng markerPos) {
    Marker marker = Marker(
        point: markerPos,
        builder: (context) => Container(
              child: IconButton(
                icon: const Icon(Icons.location_on),
                onPressed: () => print("pressed"),
              ),
            ));
    markerList.add(marker);
    setState(() {});
  }

  void updatePosition(Position position) {
    print(position == null
        ? 'Unknown'
        : 'update ${position.latitude.toString()}, ${position.longitude.toString()}');
    print(isTracking ? "tracking" : "not tracking");
    if (position != null) {
      currentPos = position;
      // mapController.move(centerLatLng!, mapController.zoom);
      setState(() {});
    }

    if (mapController == null) {
      print("mapController is not itialized");
    } else {
      print("mapController.move");
      if (_locationBloc.state.isTracking) {
        Timer(const Duration(milliseconds: 100), () {
          print("XXXX");
          mapController.move(
              LatLng(currentPos!.latitude, currentPos!.longitude), 16);
        });
      }
    }

    if (_locationBloc.state.activeLocatons?.length != 0) {
      // アクティブな位置がなければこれ以上処理をする必要がないのでreturn
      return;
    }
    // 距離を確認して近ければ通知を出す機能（仮）
    double distance = Geolocator.distanceBetween(currentPos!.latitude,
        currentPos!.longitude, 34.70784266877442, 135.63899221860058);
    print("distance: $distance");
    if (distance <= 100) {
      AppUtil.notify(
          title: "通知", body: "目的に近づきました。", id: AppUtil.STABLE_NOTIFICATION_ID);
    }
    // AppUtil.notify(
    //     title: "通知",
    //     body: "目的地までの距離 ${distance}m。",
    //     id: AppUtil.UPDATE_NOTIFICATION_ID,
    //     playSound: false,
    //     vib: false);
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
