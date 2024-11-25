import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'package:smart_bin/utils/maps_methods.dart';

import '../../models/container.dart';
import '../../services/api.dart';

part 'maps_event.dart';
part 'maps_state.dart';

class MapsBloc extends Bloc<MapsEvent, MapsState> {
  Set<Polyline> _polylineCoordinates = {};
  Set<Polyline> get polylineCoordinates => _polylineCoordinates;
  Completer<GoogleMapController>? _mapCompleterController;
  Completer<GoogleMapController> get mapCompleterController =>
      _mapCompleterController!;
  CameraPosition _currentPosition = const CameraPosition(
    target: LatLng(0, 0),
    zoom: 15,
  );
  CameraPosition get currentPosition => _currentPosition;
  GoogleMapController? _mapController;
  GoogleMapController get mapController => _mapController!;

  Set<Marker> _markers = {};
  Set<Marker> get markers => _markers;
  final services = Api();
  Trash? _nearestContainer;
  Trash? get nearestContainer => _nearestContainer;
  MapsBloc() : super(MapsInitial()) {
    on<InitializeMapEvent>((event, emit) async {
      _currentPosition = await MapsMethods().getCurrentUserCameraPosition();
      //_style = await MapsMethos().getJsonStyle("assets/styles/maps.json");
      _mapController = event.controller;

      _mapController!
          .moveCamera(CameraUpdate.newCameraPosition(_currentPosition));

      // emit(const InitializedMapsState());
    });

    on<GetNearbyContainersEvent>((event, emit) async {
      final icon = await MapsMethods().getMarkerIcon();
      emit(LoadingState());

      try {
        final containers = await services.getAllContainers();
        if (containers.isEmpty) {
          return;
        } else {
          Trash nearestContainer = await MapsMethods()
              .getNearbyContainer(containers, currentPosition.target);

          _nearestContainer = nearestContainer;
          final distance = await MapsMethods().calculateDistance(
            nearestContainer.latitude,
            nearestContainer.longitude,
          );
          _nearestContainer!.distace = distance;

          _nearestContainer!.timeTaken =
              await MapsMethods().calculateEstimatedTime(distance);
          _markers = MapsMethods().getMarkers(
            [nearestContainer],
            icon,
            (location) {
              print(location.id);
            },
          );
          final pints = await MapsMethods().showRouteBetweenUserAndBin(
            LatLng(
              _nearestContainer!.latitude,
              _nearestContainer!.longitude,
            ),
          );
          _polylineCoordinates = {
            Polyline(
              polylineId: const PolylineId("route"),
              color: Colors.blueAccent,
              width: 5,
              points: pints,
            ),
          };
          mapController.animateCamera(
            CameraUpdate.newLatLngBounds(
              await MapsMethods().getBounds(
                LatLng(
                    _nearestContainer!.latitude, _nearestContainer!.longitude),
              ),
              100,
            ),
          );
          emit(LoadedState());
        }

        print("success getting containers");

        print(_markers.length);
      } catch (e) {
        print(e);
        emit(ErrorState(e.toString()));
      }
    });

    on<StopNavigationEvent>((event, emit) async {
      _polylineCoordinates = {};
    });
  }
}
