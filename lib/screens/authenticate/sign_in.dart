import 'package:attendance_log_with_firebase/services/auth.dart';
import 'package:attendance_log_with_firebase/shared/constants.dart';
import 'package:attendance_log_with_firebase/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> with TickerProviderStateMixin {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  AnimationController _controller;
  Animation<Color> _color;

  // text field state
  String email = '';
  String password = '';
  String error = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _color = colorAppBarTween.animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return loading
        ? Loading()
        : AnimatedBuilder(
            animation: _color,
            builder: (BuildContext context, Widget child) {
              return Scaffold(
                backgroundColor: colorBackground,
                appBar: AppBar(
                  backgroundColor: _color.value,
                  elevation: 0.0,
                  title: Text('Авторизация'),
                ),
                body: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: bottom),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 50.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            SizedBox(height: 20.0),
                            TextFormField(
                              decoration: textInputDecoration.copyWith(
                                  hintText: 'Логин'),
                              validator: (val) =>
                                  val.isEmpty ? 'Введите логин' : null,
                              onChanged: (val) {
                                setState(
                                    () => email = val + '@attlogproject.al');
                              },
                            ),
                            SizedBox(height: 20.0),
                            TextFormField(
                              decoration: textInputDecoration.copyWith(
                                  hintText: 'Пароль'),
                              obscureText: true,
                              validator: (val) => val.length < 6
                                  ? 'Длина пароля должна превышать\n6 символов'
                                  : null,
                              onChanged: (val) {
                                setState(() => password = val);
                              },
                            ),
                            SizedBox(height: 20.0),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: _color.value,
                                  onPrimary: Colors.black),
                              child: Text(
                                'Войти',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState.validate()) {
                                  setState(() => loading = true);
                                  dynamic result =
                                      await _auth.signInWithEmailAndPassword(
                                          email, password);
                                  if (result == null) {
                                    setState(() {
                                      error =
                                          'Ошибка входа. Проверьте правильность введенных данных';
                                      loading = false;
                                    });
                                  }
                                }
                              },
                            ),
                            SizedBox(height: 20.0),
                            Text(
                              error,
                              style:
                                  TextStyle(color: Colors.red, fontSize: 14.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
  }
}
