// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'maps_bloc.dart';

@immutable
abstract class MapsEvent {}

class InitializeMapEvent extends MapsEvent {
  final GoogleMapController controller;
  InitializeMapEvent({
    required this.controller,
  });
}

class GetNearbyContainersEvent extends MapsEvent {
  final double longitude;
  final double latitude;

  GetNearbyContainersEvent(this.longitude, this.latitude);
}

class StartNavigationEvent extends MapsEvent {}

class StopNavigationEvent extends MapsEvent {}
