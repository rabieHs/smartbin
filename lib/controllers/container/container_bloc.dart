import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'package:smart_bin/models/container.dart';
import 'package:smart_bin/services/api.dart';

import '../../utils/maps_methods.dart';

part 'container_event.dart';
part 'container_state.dart';

class ContainerBloc extends Bloc<ContainerEvent, ContainerState> {
  List<Trash> _containers = [];
  List<Trash> _favouriteContainers = [];
  List<Trash> get container => _containers;
  List<Trash> get favouriteContainers => _favouriteContainers;
  ContainerBloc() : super(ContainerInitial()) {
    final services = Api();
    on<GetNearbyContainersEvent>((event, emit) async {
      try {
        emit(LoadingGetNearbyContainersState());
        final LatLng userPosition =
            await MapsMethods().getCurrentUserPosition();
        final containers = await services.getAllContainers();
        final nearbyContainers = await MapsMethods()
            .getNearbyContainersInRange(containers, userPosition);
        emit(LoadedGetNearbyContainersState(nearbyContainers));
        _containers = nearbyContainers;
      } catch (e) {
        emit(ErrorGetNearbyContainersState(e.toString().split(":").last));
      }

      // TODO: implement event handler
    });
    on<AddContainerToFavouriteEvent>((event, emit) async {
      try {
        await services.addToFavorites(event.id);
        emit(SuccessAddContainerState());
        emit(LoadedGetNearbyContainersState(_containers));
      } catch (e) {
        if (e.toString().contains("already in favorites")) {
          emit(ErrorAddContainerState(message: e.toString()));
        }
        emit(ErrorAddContainerState(message: e.toString()));
      }
    });

    on<GetFavouriteContainersEvent>((event, emit) async {
      try {
        emit(LoadingGetFavouriteContainerState());
        final result = await services.getFavoriteContainers();
        _favouriteContainers = result;
        emit(SuccessGetFavouriteContainerState(containers: result));
      } catch (e) {
        emit(ErrorAddContainerState(message: e.toString().split(":").last));
      }
    });

    on<RemoveContainerFromFavouriteEvents>((event, emit) async {
      try {
        await services.removeFromFavorites(event.id);
        _favouriteContainers
            .removeWhere((container) => container.id == event.id);
        emit(SuccessRemoveContainerState());
        emit(SuccessGetFavouriteContainerState(
            containers: _favouriteContainers));
      } catch (e) {
        emit(ErrorRemoveContainerState(message: e.toString().split(":").last));
      }
    });
  }
}
