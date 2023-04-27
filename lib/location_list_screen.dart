import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:prevent_ride_pass/LocationBloc.dart';
import 'package:prevent_ride_pass/location_event.dart';
import 'package:prevent_ride_pass/location_state.dart';
import 'package:prevent_ride_pass/model/Location.dart';
import 'package:prevent_ride_pass/model/SavedLocation.dart';

class LocationListScreen extends StatefulWidget {
  const LocationListScreen({super.key});

  @override
  State<LocationListScreen> createState() => _LocationListScreenState();
}

class _LocationListScreenState extends State<LocationListScreen> {
  // List<SavedLocation> locationList = List.filled(
  //     6, SavedLocation("osaka daito", 34.707675692783965, 135.64354060391506));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("保存済みの位置一覧"),
      ),
      body: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, state) {
          print(state.allLocations?.length);
          return Column(
            children: [
              Expanded(
                  child: (state is AllLocationLoadedState ||
                          (state.allLocations != null &&
                              state.allLocations!.isNotEmpty))
                      ? ListView.builder(
                          itemCount: state.allLocations!.length,
                          itemBuilder: (context, index) {
                            SavedLocation location =
                                state.allLocations!.elementAt(index);
                            return ListTile(
                              autofocus: false,
                              title: Text(location.name),
                              onTap: () {
                                context.read<LocationBloc>().add(
                                    SetcenterLocationEvent(LatLng(
                                        location.latitude,
                                        location.longitude)));
                              },
                              subtitle: Text(
                                  "緯度: ${location.latitude} 経度: ${location.longitude}"),
                            );
                          })
                      : const Expanded(
                          child: Center(child: Text("保存された位置はありません。"))))
            ],
          );
        },
      ),
    );
  }
}
