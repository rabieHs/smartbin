part of 'container_bloc.dart';

@immutable
abstract class ContainerState {}

class ContainerInitial extends ContainerState {}

class LoadingGetNearbyContainersState extends ContainerState {}

class LoadedGetNearbyContainersState extends ContainerState {
  final List<Trash> containers;

  LoadedGetNearbyContainersState(this.containers);
}

class ErrorGetNearbyContainersState extends ContainerState {
  final String message;

  ErrorGetNearbyContainersState(this.message);
}
