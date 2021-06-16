import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/services.dart';
import 'package:little_daffy/pages/login/widgets/login_form.dart';
import 'package:little_daffy/pages/login/widgets/welcome.dart';
import 'package:little_daffy/utils/responsive.dart';

class LoginFormType{

  static final int login=0;
  static final int register=1;
  static final int forgotPassword=2;
}

class LoginPage extends StatefulWidget{
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with AfterLayoutMixin{


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
           // decoration: BoxDecoration(gradient: bgGradient()),
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
                                LoginForm(),
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
                              child: LoginForm()
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
bgGradient() {
  return LinearGradient(colors: [
    Color(0xffe3999e).withOpacity(0.7),
    Color(0xff67b289).withOpacity(0.9)
  ], begin: Alignment.topCenter, end: Alignment.bottomCenter);
}