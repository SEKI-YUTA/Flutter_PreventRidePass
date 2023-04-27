import 'package:latlong2/latlong.dart';
import 'package:prevent_ride_pass/model/SavedLocation.dart';

class LocationState {
  LatLng? center = null;
  LatLng? pickedLocation = null;
  List<SavedLocation>? allLocations = List.empty();
  List<SavedLocation>? activeLocatons = List.empty();

  LocationState(
      {LatLng? center,
      LatLng? location,
      List<SavedLocation>? allLocations,
      List<SavedLocation>? activeLocatons}) {
    this.center = center;
    this.pickedLocation = location;
    this.allLocations = allLocations;
    this.activeLocatons = activeLocatons;
  }
}

class AllLocationLoadingState extends LocationState {}

class AllLocationLoadedState extends LocationState {
  AllLocationLoadedState(LocationState currentState, List<SavedLocation> list) {
    this.center = currentState.center;
    this.pickedLocation = currentState.pickedLocation;
    this.allLocations = list;
    this.activeLocatons = currentState.activeLocatons;
  }
}
