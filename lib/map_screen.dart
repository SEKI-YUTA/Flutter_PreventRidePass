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
  Position? currentPos = null;
  List<Marker> markerList = [];
  late StreamSubscription<Position> positionStream;
  bool isTracking = true;
  _MapScreenState() {
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      print(position == null
          ? 'Unknown'
          : 'update ${position.latitude.toString()}, ${position.longitude.toString()}');
      if (position != null && isTracking) {
        currentPos = position;
        // mapController.move(centerLatLng!, mapController.zoom);
        setState(() {});
      }
      if (mapController == null) {
        print("mapController is not itialized");
      } else {
        print("mapController is ialized");
        Timer(const Duration(seconds: 1), () {
          mapController.move(
              LatLng(currentPos!.latitude, currentPos!.longitude), 16);
        });
      }
    });
  }
  @override
  void initState() {
    super.initState();
    print("initState");
    // initialize();

    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Position> _determinePosition() async {
    // bool serviceEnabled;
    // LocationPermission permission;
    // serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // if (!serviceEnabled) {
    //   return Future.error('Location services are disabled.');
    // }

    // permission = await Geolocator.checkPermission();
    // if (permission == LocationPermission.denied) {
    //   permission = await Geolocator.requestPermission();
    //   if (permission == LocationPermission.denied) {
    //     return Future.error('Location permissions are denied');
    //   }
    // }

    // if (permission == LocationPermission.deniedForever) {
    //   return Future.error(
    //       'Location permissions are permanently denied, we cannot request permissions.');
    // }
    return await Geolocator.getCurrentPosition();
  }

  Future<void> initialize() async {
    currentPos = await _determinePosition();
    print("currentPos");
    print(currentPos);
    // markerList.add();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child:
            currentPos == null ? const GettingPosWidget() : MapScreen(context));
    // : TestMap());
  }

  SafeArea TestMap() {
    return SafeArea(
      child: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
                center: LatLng(34.70781811178657, 135.64362330253846),
                zoom: 16,
                interactiveFlags: InteractiveFlag.all,
                enableScrollWheel: true,
                scrollWheelVelocity: 0.00001),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
            ],
          ),
          Positioned(
            top: 200,
            child: ElevatedButton(
                onPressed: () {
                  mapController.move(
                      LatLng(34.261643510016484, 135.26069844559623), 16);
                },
                child: Text("AAA")),
          ),
        ],
      ),
    );
  }

  Widget MapScreen(BuildContext context) {
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        if (state.center != null) {
          print("center is not null");
          isTracking = false;
          positionStream.pause();
          mapController.move(
              LatLng(state.center!.latitude, state.center!.longitude), 16);
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
                    state.center != null
                        ? Marker(
                            point: LatLng(state.center!.latitude,
                                state.center!.longitude),
                            builder: (context) =>
                                Icon(Icons.location_on_outlined))
                        : Marker(
                            point: LatLng(
                                currentPos!.latitude, currentPos!.longitude),
                            builder: (context) => const FlutterLogo())
                  ],
                ),
              ],
            ),
            Positioned(
                child: ElevatedButton(
              child: Text("Debug"),
              onPressed: () {
                positionStream.resume();
                isTracking = true;
                print(currentPos);
                // mapController.move(
                //     LatLng(currentPos!.latitude, currentPos!.longitude), 16);
                // LatLng(34.261643510016484, 135.26069844559623), 16);
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
