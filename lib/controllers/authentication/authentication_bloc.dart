import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:smart_bin/controllers/container/container_bloc.dart';
import 'package:smart_bin/models/user.dart';
import 'package:smart_bin/services/api.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  User? _user;
  User? get user => _user;
  AuthenticationBloc() : super(AuthenticationInitial()) {
    final services = Api();

    on<LoginEvent>((event, emit) async {
      emit(AuthenticationLoading());
      try {
        final user = await services.loginUser(event.email, event.password);
        if (user != null) {
          _user = user;
          emit(AuthenticationSuccess());
        } else {
          emit(AuthenticationFailure(message: "Invalid email or password"));
        }
      } catch (e) {
        emit(AuthenticationFailure(message: "Error Login"));
      }
    });

    on<GetUSerEvent>((event, emit) async {
      emit(AuthenticationLoading());
      try {
        _user = await services.getUserById();
        if (_user != null) {
          emit(AuthenticationSuccess());
        } else {
          emit(AuthenticationFailure(message: "Error getting user"));
        }
      } catch (e) {
        emit(AuthenticationFailure(message: "Error getting user"));
      }
    });

    on<RegisterEvent>((event, emit) async {
      emit(AuthenticationLoading());
      final user =
          User(name: event.name, email: event.email, password: event.password);
      try {
        await services.registerUser(user).whenComplete(() async {
          print("completed");
          _user = await services.getUserById();
        });

        if (_user != null) {
          print("user not null");
          emit(AuthenticationSuccess());
        } else {
          print("user  null");
          emit(AuthenticationFailure(message: "Error registering user"));
        }
        // Register the user
        emit(AuthenticationSuccess());
      } catch (e) {
        if (e.toString().contains("Username already exists")) {
          emit(AuthenticationFailure(message: "username already exists"));
        } else if (e.toString().contains("Email already exists")) {
          emit(AuthenticationFailure(message: "email already exists"));
        } else {
          emit(AuthenticationFailure(message: "Error registering user"));
        }
      }
    });

    on<SignOutUser>((event, emit) async {
      try {
        await services.signUserOut();
        emit(LogoutSuccess());
      } catch (e) {
        emit(LogoutFailure());
      }
    });
  }
}
