// Flutter imports:
// Project imports:
import 'package:attendance_log_with_firebase/core/domain/repositories/auth_repository.dart';
import 'package:attendance_log_with_firebase/presentation/pages/authenticate/login/bloc/login_bloc.dart';
import 'package:attendance_log_with_firebase/presentation/pages/authenticate/register/register.dart';
import 'package:attendance_log_with_firebase/presentation/widgets/custom_scaffold.dart';
import 'package:attendance_log_with_firebase/presentation/widgets/loading.dart';
import 'package:attendance_log_with_firebase/src/constants/constants_ui.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:page_transition/page_transition.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late final AuthRepository authRepository;

  late final GlobalKey<FormState> formKey;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  @override
  void initState() {
    super.initState();

    authRepository = GetIt.I.get();

    formKey = GlobalKey<FormState>();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(authRepository: authRepository),
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          if (state is LoadingLoginState) {
            return Loading();
          }

          return CustomScaffold(
            title: 'Авторизация',
            isExitButtonRequired: false,
            actions: [_getToRegisterPageButton(context)],
            body: SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  padding: const EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 50.0,
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 20.0),
                        _getEmailTextFormField(),
                        const SizedBox(height: 20.0),
                        _getPasswordTextFormField(),
                        const SizedBox(height: 20.0),
                        _getSignInButton(context),
                        const SizedBox(height: 20.0),
                        if (state is ErrorLoginState)
                          _getErrorMsg(state.message),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _getToRegisterPageButton(BuildContext context) {
    return TextButton.icon(
      icon: Icon(
        Icons.create_outlined,
        color: ConstantsUI.colorBackground,
      ),
      label: const Text(
        'Зарегистрироваться',
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () => _toRegisterPage(context),
    );
  }

  Widget _getEmailTextFormField() {
    return TextFormField(
      controller: emailController,
      decoration: ConstantsUI.textInputDecoration.copyWith(hintText: 'Логин'),
      validator: (val) => val == null || val.isEmpty ? 'Введите логин' : null,
    );
  }

  Widget _getPasswordTextFormField() {
    return TextFormField(
      controller: passwordController,
      decoration: ConstantsUI.textInputDecoration.copyWith(hintText: 'Пароль'),
      obscureText: true,
      validator: (val) {
        return val != null && val.length < 6
            ? 'Длина пароля должна превышать\n6 символов'
            : null;
      },
    );
  }

  Widget _getSignInButton(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: ConstantsUI.gradientColors),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        onPressed: () {
          if (formKey.currentState?.validate() ?? false) {
            context.read<LoginBloc>().add(
                  SignInEvent(
                    email: emailController.text.trim(),
                    password: passwordController.text,
                  ),
                );
          }
        },
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Войти',
            style: TextStyle(color: Colors.white, fontSize: 18.0),
          ),
        ),
      ),
    );
  }

  Widget _getErrorMsg(String msg) {
    return Text(
      msg,
      style: const TextStyle(color: Colors.red, fontSize: 14.0),
      textAlign: TextAlign.center,
    );
  }

  void _toRegisterPage(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageTransition(
        child: const RegisterPage(),
        alignment: Alignment.bottomCenter,
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 300),
        reverseDuration: const Duration(milliseconds: 300),
        type: PageTransitionType.rightToLeft,
      ),
    );
  }
}
