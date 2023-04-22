import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:prevent_ride_pass/util/AppUtil.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Position? currentPosition = null;
  MapController controller = MapController(
    initMapWithUserPosition: false,
    initPosition: GeoPoint(
      latitude: 34.68244923950879,
      longitude: 35.50301679852825,
    ),
  );
  @override
  void initState() {
    super.initState();
    initialize();
    // controller.currentLocation();
    print("initState end");
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  Future<void> initialize() async {
    var position = await AppUtil.getCurrentPosition();
    // print("current location -------");
    // print(position.latitude);
    // print(position.longitude);
    // print("current location ------- end");
    // controller.changeLocation(
    //     GeoPoint(latitude: position.latitude, longitude: position.longitude));
    // controller.goToLocation(
    //     GeoPoint(latitude: position.latitude, longitude: position.longitude));
    controller.currentLocation();
    // controller.getCurrentPositionAdvancedPositionPicker();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OSMFlutter(
        isPicker: true,
        controller: controller,
        trackMyPosition: false,
        initZoom: 18,
        minZoomLevel: 2,
        maxZoomLevel: 18,
        onGeoPointClicked: (point) => {print("point" + point.toString())},
        stepZoom: 1.0,
        userLocationMarker: UserLocationMaker(
          personMarker: MarkerIcon(
            icon: Icon(
              Icons.location_history_rounded,
              color: Colors.red,
              size: 48,
            ),
          ),
          directionArrowMarker: MarkerIcon(
            icon: Icon(
              Icons.double_arrow,
              size: 48,
            ),
          ),
        ),
        roadConfiguration: RoadOption(
          roadColor: Colors.yellowAccent,
        ),
        markerOption: MarkerOption(
            defaultMarker: MarkerIcon(
          icon: Icon(
            Icons.person_pin_circle,
            color: Colors.blue,
            size: 56,
          ),
        )),
      ),
    );
  }
}
