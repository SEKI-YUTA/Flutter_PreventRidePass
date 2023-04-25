import 'package:prevent_ride_pass/model/Location.dart';

class SavedLocation extends Location {
  int? id;
  late String name;
  late double latitude;
  late double longitude;
  static String tableName = "location";
  static String columnId = "_id";
  static String columnName = "name";
  static String columnLatitude = "latitude";
  static String columnLongitude = "longitude";

  SavedLocation(this.name, this.latitude, this.longitude);

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnName: name,
      columnLatitude: latitude,
      columnLongitude: longitude
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  SavedLocation.fromMap(Map<dynamic, dynamic> map) {
    id = map[columnId] as int;
    name = map[columnName] as String;
    latitude = map[columnLatitude] as double;
    longitude = map[columnLongitude] as double;
  }

  String toString() {
    return 'name: $name latitude: $latitude longitude: $longitude';
  }
}
