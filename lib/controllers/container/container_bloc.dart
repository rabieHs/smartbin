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
      } catch (e) {
        emit(ErrorGetNearbyContainersState(e.toString().split(":").last));
      }

      // TODO: implement event handler
    });
  }
}
