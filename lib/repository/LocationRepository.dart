import 'package:prevent_ride_pass/model/SavedLocation.dart';
import 'package:prevent_ride_pass/util/AppUtil.dart';
import 'package:sqflite/sqflite.dart';

class LocationRepository {
  Future<List<SavedLocation>> getAllSavedLocation() async {
    Database db = await AppUtil.openAppDatabase();
    Future<List<SavedLocation>> locationList = AppUtil.getSavedLocations(db);
    return locationList;
  }
}
