import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:flutter/cupertino.dart';
import 'package:little_daffy/pages/fire/auth.dart';
import 'package:little_daffy/utils/app_colors.dart';
import 'package:little_daffy/utils/responsive.dart';
import 'package:little_daffy/pages/home/principal.dart';
import 'package:little_daffy/widgets/circle_button.dart';
import 'package:little_daffy/widgets/rounded_button.dart';
import 'package:little_daffy/pages/login/widgets/input_text_login.dart';
import 'package:little_daffy/pages/login/widgets/registerForm/register_page.dart';
import 'package:little_daffy/pages/login/widgets/forgotPassword/password_page.dart';

class LoginForm extends StatefulWidget {
  static final routeName = 'login';
  const LoginForm({Key key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<InputTextLoginState> _emailKey = GlobalKey();
  final GlobalKey<InputTextLoginState> _passwordKey = GlobalKey();
  void _goTo(FirebaseUser user) {
    if (user != null) {
      Navigator.pushReplacementNamed(context, Principal.routeName);
    } else {
      print("login failed");
    }
  }

  Future<void> _submit() async {
    final String email = _emailKey.currentState.value;
    final String password = _passwordKey.currentState.value;

    final bool emailOk = _emailKey.currentState.isOk;
    final bool passwordOk = _passwordKey.currentState.isOk;

    if (emailOk && passwordOk) {
      final FirebaseUser user = await Auth.instance
          .loginByPassword(context, email: email, password: password);
      _goTo(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Responsive responsive = Responsive.of(context);

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Container(
          width: responsive.ip(40),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                InputTextLogin(
                  key: _emailKey,
                  iconPath: 'assets/pages/login/icons/email.svg',
                  placeholder: "Correo electronico",
                  validator: (text) {
                    return text.contains("@");
                  },
                ),
                SizedBox(
                  height: responsive.ip(2),
                ),
                InputTextLogin(
                  key: _passwordKey,
                  iconPath: 'assets/pages/login/icons/key.svg',
                  placeholder: "Password",
                  obscureText: true,
                  validator: (text) {
                    return text.trim().length >= 6;
                  },
                ),
                Container(
                  width: double.infinity,
                  alignment: Alignment.centerRight,
                  child: CupertinoButton(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        "¿Olvidaste tu contraseña?",
                        style:
                            TextStyle(fontFamily: 'luxia', color: Colors.blue),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PasswordPage()),
                        );
                      }),
                ),
                SizedBox(
                  height: responsive.ip(2),
                ),
                RoundedButton(
                    label: "Ingresar",
                    //backgroundColor: AppColors.letras,
                    onPressed: this._submit),
                SizedBox(
                  height: responsive.ip(3.3),
                ),
                Text(
                  "───────────  O  ───────────",
                  style: TextStyle(
                      color: AppColors.gray,
                      fontWeight: FontWeight.bold,
                      fontSize: responsive.ip(1.2)),
                ),
                SizedBox(
                  height: responsive.ip(1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircleButton(
                      size: responsive.ip(7),
                      backgroundColor: Color(0xff448AFF),
                      iconPath: "assets/pages/login/icons/facebook.svg",
                      onPressed: () async {
                        await Auth.instance.facebook();
                        print("listo");
                      },
                    ),
                    SizedBox(
                      width: responsive.ip(2),
                    ),
                    CircleButton(
                      size: responsive.ip(7),
                      backgroundColor: Color(0xffFF1744),
                      iconPath: "assets/pages/login/icons/google.svg",
                      onPressed: () async {
                        final user = await Auth.instance.google();
                        _goTo(user);
                      },
                    )
                  ],
                ),
                SizedBox(
                  height: responsive.ip(2),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("¿No tienes una cuenta?"),
                    CupertinoButton(
                      child: Text(
                        "Registrate",
                        style: TextStyle(
                            fontFamily: 'luxia',
                            fontWeight: FontWeight.w600,
                            color: Colors.blue),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterPage()),
                        );
                      },
                    )
                  ],
                ),
              ]),
        ),
      ),
    );
  }
}
