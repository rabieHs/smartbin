// ignore_for_file: public_member_api_docs, sort_constructors_first
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

class SuccessAddContainerState extends ContainerState {}

class SuccessGetFavouriteContainerState extends ContainerState {
  List<Trash> containers;
  SuccessGetFavouriteContainerState({
    required this.containers,
  });
}

class ErrorAddContainerState extends ContainerState {
  final String message;
  ErrorAddContainerState({
    required this.message,
  });
}

class ErrorGetFavouriteContainerState extends ContainerState {
  final String message;
  ErrorGetFavouriteContainerState({
    required this.message,
  });
}

class SuccessRemoveContainerState extends ContainerState {}

class LoadingGetFavouriteContainerState extends ContainerState {}

class ErrorRemoveContainerState extends ContainerState {
  final String message;
  ErrorRemoveContainerState({
    required this.message,
  });
}
