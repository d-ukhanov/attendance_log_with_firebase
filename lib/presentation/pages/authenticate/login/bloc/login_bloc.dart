// Dart imports:
import 'dart:async';

// Project imports:
import 'package:attendance_log_with_firebase/core/domain/repositories/auth_repository.dart';
import 'package:attendance_log_with_firebase/utils/logger.dart';

// Package imports:
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

part 'login_event.dart';

part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;

  LoginBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(InitialLoginState()) {
    on<SignInEvent>(
      (event, emit) async => _signIn(
        emit: emit,
        email: event.email,
        password: event.password,
      ),
    );
  }

  Future<void> _signIn({
    required Emitter<LoginState> emit,
    required String email,
    required String password,
  }) async {
    emit(LoadingLoginState());

    try {
      final dynamic result = await _authRepository
          .signInWithEmailAndPassword(email, password)
          .timeout(const Duration(seconds: 10));

      if (result == null) {
        emit(
          ErrorLoginState(
            'Ошибка входа. Проверьте правильность введенных данных',
          ),
        );
      }
    } on TimeoutException {
      emit(
        ErrorLoginState(
          'Время ожидания подключения истекло, проверьте подключение к Интернету',
        ),
      );
    } on FirebaseException catch (e) {
      emit(ErrorLoginState(e.message ?? 'Ошибка входа'));
    } catch (e) {
      Log.logger.w(e);

      emit(ErrorLoginState('Ошибка входа'));

      rethrow;
    }
  }
}
