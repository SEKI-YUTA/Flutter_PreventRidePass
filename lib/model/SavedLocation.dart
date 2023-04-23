import 'package:prevent_ride_pass/model/Location.dart';

class SavedLocation extends Location {
  late String name;
  late double latitude;
  late double longitude;

  SavedLocation(this.name, this.latitude, this.longitude);

  String toString() {
    return 'name: $name latitude: $latitude longitude: $longitude';
  }
}
