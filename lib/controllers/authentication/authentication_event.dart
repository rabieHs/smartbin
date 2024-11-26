part of 'authentication_bloc.dart';

@immutable
abstract class AuthenticationEvent {}

class LoginEvent extends AuthenticationEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});
}

class RegisterEvent extends AuthenticationEvent {
  final String name;
  final String email;
  final String password;

  RegisterEvent({
    required this.name,
    required this.email,
    required this.password,
  });
}

class GetUSerEvent extends AuthenticationEvent {}

class SignOutUser extends AuthenticationEvent {}
