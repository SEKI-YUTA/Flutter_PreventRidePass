import 'package:latlong2/latlong.dart';
import 'package:prevent_ride_pass/model/SavedLocation.dart';

abstract class LocationEvent {}

class ToggleIsTrackingEvent extends LocationEvent {
  bool isTracking;
  ToggleIsTrackingEvent(this.isTracking);
}

class SetcenterLocationEvent extends LocationEvent {
  LatLng center;
  SetcenterLocationEvent(this.center);
}

class ResetCenterLocationEvent extends LocationEvent {}

class SetPickedLocationEvent extends LocationEvent {
  LatLng location;
  SetPickedLocationEvent(this.location);
}

class ResetPickedLocationEvent extends LocationEvent {}

class LoadAllLocation extends LocationEvent {}

class SetAllLocationEvent extends LocationEvent {
  List<SavedLocation> allLocations;
  SetAllLocationEvent(this.allLocations);
}

class AddLocationToAllLocation extends LocationEvent {
  SavedLocation location;
  AddLocationToAllLocation(this.location);

  get allLocations => this.allLocations;
}

class ClearAllLocationEvent extends LocationEvent {}

class SetActiveLocationListEvent extends LocationEvent {
  List<SavedLocation> activeLocatons;
  SetActiveLocationListEvent(this.activeLocatons);
}

class AddLocationToActiveLocationList extends LocationEvent {
  SavedLocation location;
  AddLocationToActiveLocationList(this.location);
}

class ClearActiveLocationListEvent extends LocationEvent {}
