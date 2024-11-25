part of 'maps_bloc.dart';

@immutable
sealed class MapsState {}

final class MapsInitial extends MapsState {}

class LoadingState extends MapsState {}

class LoadedState extends MapsState {
  LoadedState();
}

class ErrorState extends MapsState {
  final String message;

  ErrorState(this.message);
}
