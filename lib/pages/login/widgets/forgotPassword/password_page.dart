import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/services.dart';
import 'package:little_daffy/pages/login/widgets/forgotPassword/forgot_password_form.dart';
import 'package:little_daffy/pages/login/widgets/welcome.dart';
import 'package:little_daffy/utils/responsive.dart';


class PasswordPage extends StatefulWidget{
  PasswordPage({Key key}) : super(key: key);

  @override
  _PasswordPageState createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> with AfterLayoutMixin{


  @override
  void initState(){
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    if (!isTablet) {
      // bloquear rotacion smartphone
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  


  @override
  Widget build(BuildContext context){
    final Responsive responsive = Responsive.of(context);
    return Scaffold(
      body: GestureDetector(
          onTap: (){
            FocusScope.of(context).unfocus();
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            child: OrientationBuilder(
              builder: (_, Orientation orientation) {
              if(orientation == Orientation.portrait){
                return SingleChildScrollView(
                  child: Container(
                    height: responsive.height,
                    child: Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          
                          Welcome(),
                          Expanded(
                            child: ListView(
                              //physics: NeverScrollableScrollPhysics(),
                              children: <Widget>[
                                ForgotPasswordForm()
                              ]
                            ),
                          ),
                        ], 
                      ),
                    ),
                  ),
                );
              } else {
                return Row(
                  children: <Widget>[
                    Expanded(
                        child: SingleChildScrollView(
                          physics: NeverScrollableScrollPhysics(),
                          child: Container(
                            padding: EdgeInsets.only(left: 20),
                            height: responsive.height,
                            child: Center(
                              child: Welcome(),
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: SingleChildScrollView(
                          child: Container(
                            height: responsive.height,
                            child: Center(
                              child: ForgotPasswordForm()
                            ),
                          ),
                        ),
                    )
                  ],
                );
              }
            },
          ), 
          ),
      ),

    );
  }

}