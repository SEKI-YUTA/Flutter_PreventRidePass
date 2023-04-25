import 'package:bloc/bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:prevent_ride_pass/LocationState.dart';
import 'package:prevent_ride_pass/model/SavedLocation.dart';

abstract class LocationStateEvent {}

class SetPickedLocationEvent extends LocationStateEvent {
  LatLng location;
  SetPickedLocationEvent(this.location);
}

class ResetPickedLocationEvent extends LocationStateEvent {}

class GetAllLocationEvent extends LocationStateEvent {
  GetAllLocationEvent();
}

class SetAllLocationEvent extends LocationStateEvent {
  List<SavedLocation> allLocations;
  SetAllLocationEvent(this.allLocations);
}

class AddLocationToAllLocation extends LocationStateEvent {
  SavedLocation location;
  AddLocationToAllLocation(this.location);
}

class ClearAllLocationEvent extends LocationStateEvent {}

class SetActiveLocationListEvent extends LocationStateEvent {
  List<SavedLocation> activeLocatons;
  SetActiveLocationListEvent(this.activeLocatons);
}

class AddLocationToActiveLocationList extends LocationStateEvent {
  SavedLocation location;
  AddLocationToActiveLocationList(this.location);
}

class ClearActiveLocationListEvent extends LocationStateEvent {}

class LocationBloc extends Bloc<LocationStateEvent, LocationState> {
  LocationBloc() : super(LocationState()) {
    on<SetPickedLocationEvent>((event, emit) {
      emit(LocationState(location: event.location));
    });
    on<ResetPickedLocationEvent>((event, emit) {
      emit(LocationState(location: null));
    });
    on<AddLocationToAllLocation>((event, emit) {
      emit(
          LocationState(allLocations: state.allLocations!.add(event.location)));
    });
    on<GetAllLocationEvent>((event, emit) {});
    on<SetAllLocationEvent>((event, emit) {
      emit(LocationState(allLocations: event.allLocations));
    });
    on<ClearAllLocationEvent>((event, emit) {
      emit(LocationState(allLocations: null));
    });
    on<SetActiveLocationListEvent>((event, emit) {
      emit(LocationState(activeLocatons: event.activeLocatons));
    });
    on<ClearActiveLocationListEvent>((event, emit) {
      emit(LocationState(activeLocatons: null));
    });
  }

  @override
  void onChange(Change<LocationState> change) {
    super.onChange(change);
    print("changed");
  }
}
