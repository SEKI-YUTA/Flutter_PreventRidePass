import 'package:latlong2/latlong.dart';
import 'package:prevent_ride_pass/model/SavedLocation.dart';

class LocationState {
  bool isTracking = true;
  LatLng? center = null;
  LatLng? pickedLocation = null;
  List<SavedLocation>? allLocations = List.empty();
  List<SavedLocation> activeLocatons = List.empty();

  LocationState(
      {bool isTracking = true,
      LatLng? center,
      LatLng? location,
      List<SavedLocation>? allLocations,
      List<SavedLocation>? activeLocatons}) {
    this.isTracking = isTracking;
    this.center = center;
    this.pickedLocation = location;
    this.allLocations = allLocations;
    if (activeLocatons == null) {
      this.activeLocatons = List.empty(growable: true);
    } else {
      this.activeLocatons = activeLocatons;
    }
  }
}

class AllLocationLoadingState extends LocationState {}

class AllLocationLoadedState extends LocationState {
  AllLocationLoadedState(LocationState currentState, List<SavedLocation> list) {
    this.isTracking = currentState.isTracking;
    this.center = currentState.center;
    this.pickedLocation = currentState.pickedLocation;
    this.allLocations = list;
    this.activeLocatons = currentState.activeLocatons;
  }
}
