// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:smart_bin/controllers/maps/maps_bloc.dart';
import 'package:smart_bin/views/bins.dart';
import 'package:smart_bin/views/favourites.dart';
import 'package:smart_bin/views/home.dart';

import '../widgets/data_widget.dart';

class Maps extends StatefulWidget {
  const Maps({super.key});

  @override
  State<Maps> createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  @override
  Widget build(BuildContext context) {
    final map = BlocProvider.of<MapsBloc>(context);
    return Scaffold(
      body: BlocConsumer<MapsBloc, MapsState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Stack(
            children: [
              Expanded(
                child: GoogleMap(
                  trafficEnabled: true,
                  myLocationEnabled: true,
                  initialCameraPosition: map.currentPosition,
                  mapType: MapType.terrain,
                  onMapCreated: (controller) {
                    map.add(InitializeMapEvent(controller: controller));
                    BlocProvider.of<MapsBloc>(context).add(
                        GetNearbyContainersEvent(
                            map.currentPosition.target.longitude,
                            map.currentPosition.target.latitude));
                  },
                  markers: BlocProvider.of<MapsBloc>(context).markers,
                  polylines:
                      BlocProvider.of<MapsBloc>(context).polylineCoordinates,
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 15).copyWith(top: 50),
                height: 100,
                width: double.infinity,
                child: Card(
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ContainerDataWidget(
                        title: "Time",
                        value: BlocProvider.of<MapsBloc>(context)
                                    .nearestContainer !=
                                null
                            ? "${BlocProvider.of<MapsBloc>(context).nearestContainer!.timeTaken} min"
                            : "0.0 min",
                        image: "time",
                      ),
                      ContainerDataWidget(
                        title: "Distance",
                        value: BlocProvider.of<MapsBloc>(context)
                                    .nearestContainer !=
                                null
                            ? "${BlocProvider.of<MapsBloc>(context).nearestContainer!.distace} KM"
                            : "0.0 KM",
                        image: "distance",
                      ),
                      ContainerDataWidget(
                        title: "Value",
                        value: BlocProvider.of<MapsBloc>(context)
                                    .nearestContainer !=
                                null
                            ? "${BlocProvider.of<MapsBloc>(context).nearestContainer!.volume} %"
                            : "00 %",
                        image: "bin",
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
