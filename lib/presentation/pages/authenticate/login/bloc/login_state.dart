part of 'login_bloc.dart';

@immutable
abstract class LoginState {}

class InitialLoginState extends LoginState {}

class LoadingLoginState extends LoginState {}

class ErrorLoginState extends LoginState {
  final String message;

  ErrorLoginState(this.message);
}
