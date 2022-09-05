// Dart imports:
import 'dart:async';

// Project imports:
import 'package:attendance_log_with_firebase/core/domain/repositories/auth_repository.dart';
import 'package:attendance_log_with_firebase/utils/logger.dart';

// Package imports:
import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:meta/meta.dart';

part 'register_event.dart';

part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository _authRepository;

  RegisterBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(InitialRegisterState()) {
    on<SignUpEvent>(
      (event, emit) async => _signUp(
        emit: emit,
        email: event.email,
        password: event.password,
      ),
    );
  }

  Future<void> _signUp({
    required Emitter<RegisterState> emit,
    required String email,
    required String password,
  }) async {
    emit(LoadingRegisterState());

    try {
      final dynamic result = await _authRepository
          .createUserWithEmailAndPassword(email, password)
          .timeout(const Duration(seconds: 10));

      if (result == null) {
        emit(
          ErrorRegisterState(
            'Ошибка регистрации. Проверьте правильность введенных данных',
          ),
        );
      } else {
        emit(SuccessRegisterState());
      }
    } on TimeoutException {
      emit(
        ErrorRegisterState(
          'Время ожидания подключения истекло, проверьте подключение к Интернету',
        ),
      );
    } on FirebaseException catch (e) {
      emit(ErrorRegisterState(e.message ?? 'Ошибка регистрации'));
    } catch (e) {
      Log.logger.w(e);

      emit(ErrorRegisterState('Ошибка регистрации'));

      rethrow;
    }
  }
}
