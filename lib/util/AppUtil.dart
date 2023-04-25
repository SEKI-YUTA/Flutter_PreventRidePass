import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart';
import 'package:prevent_ride_pass/AppConstantValues.dart';
import 'package:prevent_ride_pass/model/SavedLocation.dart';
import 'package:sqflite/sqflite.dart';

class AppUtil {
  static void demo() {
    print("demo");
  }

  static Future<Database> openAppDatabase() async {
    return openDatabase(
        join(await getDatabasesPath(), AppConstantValues.dbName),
        onCreate: (db, version) {
      return db.execute(
          "CREATE TABLE ${SavedLocation.tableName}(${SavedLocation.columnId} INTEGER PRIMARY KEY AUTOINCREMENT," +
              "${SavedLocation.columnName} TEXT, ${SavedLocation.columnLatitude} REAL, ${SavedLocation.columnLongitude} REAL)");
    }, version: 1);
  }

  static Future<List<SavedLocation>> getSavedLocations(Database db) async {
    final List<Map<String, dynamic>> maps =
        await db.query(SavedLocation.tableName);
    return List.generate(maps.length, (index) {
      Map item = maps[index];
      return SavedLocation.fromMap(item);
    });
  }

  static Future<void> notify() {
    final flnp = FlutterLocalNotificationsPlugin();
    return flnp
        .initialize(
          InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          ),
        )
        .then((_) => flnp.show(
            0,
            'title',
            'body',
            NotificationDetails(
              android: AndroidNotificationDetails(
                'channel_id',
                'channel_name',
              ),
            )));
  }

  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
