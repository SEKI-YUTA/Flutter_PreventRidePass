import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:prevent_ride_pass/model/Location.dart';
import 'package:prevent_ride_pass/model/SavedLocation.dart';

class LocationListScreen extends StatefulWidget {
  const LocationListScreen({super.key});

  @override
  State<LocationListScreen> createState() => _LocationListScreenState();
}

class _LocationListScreenState extends State<LocationListScreen> {
  List<SavedLocation> locationList = List.filled(
      6, SavedLocation("osaka daito", 34.707675692783965, 135.64354060391506));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("保存済みの位置一覧"),
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
                  itemCount: locationList.length,
                  itemBuilder: (context, index) {
                    SavedLocation location = locationList.elementAt(index);
                    return ListTile(
                      autofocus: false,
                      title: Text(location.name),
                      subtitle: Text(
                          "緯度: ${location.latitude} 経度: ${location.longitude}"),
                    );
                  }))
        ],
      ),
    );
  }
}
