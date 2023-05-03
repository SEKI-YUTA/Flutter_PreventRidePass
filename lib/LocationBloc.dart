import 'package:bloc/bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:prevent_ride_pass/location_state.dart';
import 'package:prevent_ride_pass/location_event.dart';
import 'package:prevent_ride_pass/model/SavedLocation.dart';
import 'package:prevent_ride_pass/repository/LocationRepository.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc() : super(LocationState()) {
    on<ToggleIsTrackingEvent>((event, emit) {
      emit(LocationState(
          isTracking: event.isTracking,
          center: state.center,
          location: state.pickedLocation,
          allLocations: state.allLocations,
          activeLocatons: state.activeLocatons));
    });
    on<SetcenterLocationEvent>((event, emit) {
      emit(LocationState(
          center: event.center,
          location: state.pickedLocation,
          allLocations: state.allLocations,
          activeLocatons: state.activeLocatons));
    });
    on<ResetCenterLocationEvent>((event, emit) {
      emit(LocationState(
          center: null,
          location: state.pickedLocation,
          allLocations: state.allLocations,
          activeLocatons: state.activeLocatons));
    });
    on<SetPickedLocationEvent>((event, emit) {
      print("pick len ${state.allLocations?.length} ");
      emit(LocationState(
          center: state.center,
          location: event.location,
          allLocations: state.allLocations,
          activeLocatons: state.activeLocatons));
    });
    on<ResetPickedLocationEvent>((event, emit) {
      emit(LocationState(
          center: state.center,
          location: null,
          allLocations: state.allLocations,
          activeLocatons: state.activeLocatons));
    });
    on<LoadAllLocation>((event, emit) async {
      emit(AllLocationLoadingState());

      List<SavedLocation> allSavedLocation =
          await LocationRepository().getAllSavedLocation();
      emit(AllLocationLoadedState(state, allSavedLocation));
    });
    on<AddLocationToAllLocation>((event, emit) {
      // print("add ${event.location.name}");
      // print("len ${state.allLocations?.length}");
      // print("len ${event.allLocations?.length}");
      emit(LocationState(
          center: state.center,
          location: state.pickedLocation,
          allLocations: state.allLocations?..add(event.location),
          activeLocatons: state.activeLocatons));
    });
    on<SetAllLocationEvent>((event, emit) {
      emit(LocationState(
          center: state.center,
          location: state.pickedLocation,
          allLocations: event.allLocations,
          activeLocatons: state.activeLocatons));
    });
    on<ClearAllLocationEvent>((event, emit) {
      emit(LocationState(
          center: state.center,
          location: state.pickedLocation,
          allLocations: null,
          activeLocatons: state.activeLocatons));
    });
    on<SetActiveLocationListEvent>((event, emit) {
      emit(LocationState(
          center: state.center,
          location: state.pickedLocation,
          allLocations: state.allLocations,
          activeLocatons: event.activeLocatons));
    });
    on<ClearActiveLocationListEvent>((event, emit) {
      emit(LocationState(
          center: state.center,
          location: state.pickedLocation,
          allLocations: state.allLocations,
          activeLocatons: null));
    });
  }

  @override
  void onChange(Change<LocationState> change) {
    super.onChange(change);
    print("changed");
  }
}
