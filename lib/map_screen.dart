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
import 'package:prevent_ride_pass/model/SavedLocation.dart';
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
  // bool isTracking = true;
  bool isStopped = false;
  bool isRinging = false;

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
    _locationBloc = BlocProvider.of(context);
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
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
        if (state.center != null && !state.isTracking) {
          // print("center is not null");
          // isTracking = false;
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
                    addMarker(point);
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
          print("XXXX");
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
        if (distance <= 100 && (!isRinging && !isStopped)) {
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
