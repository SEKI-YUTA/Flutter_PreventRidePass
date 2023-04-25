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
import 'package:prevent_ride_pass/util/AppUtil.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );
  Position? currentPos = null;
  List<Marker> markerList = [];
  @override
  void initState() {
    super.initState();
    initialize();

    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      print(position == null
          ? 'Unknown'
          : '${position.latitude.toString()}, ${position.longitude.toString()}');
      if (position != null) {
        currentPos = position;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<void> initialize() async {
    currentPos = await _determinePosition();
    print("currentPos");
    print(currentPos);
    markerList.add(Marker(
        point: LatLng(currentPos!.latitude, currentPos!.longitude),
        builder: (context) => FlutterLogo()));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: currentPos == null
          ? const GettingPosWidget()
          : FlutterMap(
              options: MapOptions(
                  onTap: (tapPosition, point) {
                    Fluttertoast.showToast(
                        msg: "lat: ${point.latitude} lon: ${point.longitude} ");
                    context
                        .read<LocationBloc>()
                        .add(SetPickedLocationEvent(point));
                    addMarker(point);
                  },
                  center: LatLng(currentPos!.latitude, currentPos!.longitude),
                  zoom: 14,
                  interactiveFlags: InteractiveFlag.all,
                  enableScrollWheel: true,
                  scrollWheelVelocity: 0.00001),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                MarkerLayer(
                  markers: markerList,
                )
              ],
            ),
    );
  }

  void addMarker(LatLng markerPos) {
    Marker marker = Marker(
        point: markerPos,
        builder: (context) => Container(
              child: IconButton(
                icon: Icon(Icons.location_on),
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
