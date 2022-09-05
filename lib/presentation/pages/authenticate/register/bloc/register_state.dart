part of 'register_bloc.dart';

@immutable
abstract class RegisterState {}

class InitialRegisterState extends RegisterState {}

class LoadingRegisterState extends RegisterState {}

class SuccessRegisterState extends RegisterState {}

class ErrorRegisterState extends RegisterState {
  final String message;

  ErrorRegisterState(this.message);
}
