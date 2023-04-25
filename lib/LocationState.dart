import 'package:latlong2/latlong.dart';
import 'package:prevent_ride_pass/model/SavedLocation.dart';

class LocationState {
  LatLng? pickedLocation = null;
  List<SavedLocation>? allLocations = List.empty();
  List<SavedLocation>? activeLocatons = List.empty();

  LocationState(
      {LatLng? location,
      List<SavedLocation>? allLocations,
      List<SavedLocation>? activeLocatons}) {
    this.pickedLocation = location;
    this.allLocations = allLocations;
    this.activeLocatons = activeLocatons;
  }

  void test() {
    allLocations!.add(SavedLocation("AA", 33, 55));
  }
}
