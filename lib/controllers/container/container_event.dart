// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'container_bloc.dart';

@immutable
abstract class ContainerEvent {}

class GetNearbyContainersEvent extends ContainerEvent {}

class GetFavouriteContainersEvent extends ContainerEvent {}

class AddContainerToFavouriteEvent extends ContainerEvent {
  final String id;
  AddContainerToFavouriteEvent({
    required this.id,
  });
}

class RemoveContainerFromFavouriteEvents extends ContainerEvent {
  final String id;
  RemoveContainerFromFavouriteEvents({
    required this.id,
  });
}
