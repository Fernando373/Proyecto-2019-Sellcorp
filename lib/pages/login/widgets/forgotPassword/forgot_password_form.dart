import "package:flutter/material.dart";
import 'package:flutter/cupertino.dart';
import 'package:little_daffy/pages/login/login_page.dart';
import 'package:little_daffy/pages/login/widgets/input_text_login.dart';
import 'package:little_daffy/utils/app_colors.dart';
import 'package:little_daffy/utils/responsive.dart';
import 'package:little_daffy/widgets/rounded_button.dart';

class ForgotPasswordForm extends StatefulWidget {
  
  const ForgotPasswordForm({Key key}) : super(key: key);

  @override
  _ForgotPasswordFormState createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {

  @override
  Widget build(BuildContext context) {
    
    final Responsive responsive = Responsive.of(context);
    
    return Align(
      alignment: Alignment.center,
          child: SafeArea(
          top: false,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
          constraints: BoxConstraints(
            maxWidth: responsive.ip(50) 
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("RECUPERAR TU CONTRASEÑA", 
              style: TextStyle(
                color: AppColors.letras1,
                fontFamily: 'luxia',
                fontSize: responsive.ip(3),
                fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(
                height: responsive.ip(1),
              ),
              Text("▼ Ingresa tú correo electronico para poder recuperar tu contraseña", 
                style: TextStyle(
                  fontWeight: FontWeight.w300
                ),
              ),
              SizedBox(
                height: responsive.ip(5),
              ),
              InputTextLogin(iconPath: 'assets/pages/login/icons/email.svg', placeholder: "Correo electronico"),
              SizedBox(
                height: responsive.ip(3),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end ,
                children: <Widget>[
                  FlatButton(
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    }, 
                    child: Text("← Volver al inicio"),
                  ),
                  SizedBox(
                    width: responsive.ip(1.9)
                  ),
                  RoundedButton(
                    label: "Enviar",
                    //backgroundColor: AppColors.letras,
                    onPressed: () {

                    } 
                  ),
                ],
              ),
              SizedBox(
                height: responsive.ip(1.5),
              ),
              
            ]
          ),
        ),
      ),
    );
  }
}