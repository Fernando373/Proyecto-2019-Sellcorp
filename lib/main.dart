import 'package:flutter/material.dart';
import 'package:little_daffy/pages/home/principal.dart';
import 'package:little_daffy/pages/login/login_page.dart';
import 'package:little_daffy/pages/registro/widgets/registro_form.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // theme: ThemeData.dark(),
      title: 'Little Daffy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.cyan, fontFamily: 'luxia'),
      home: LoginPage(),
      routes: { 
        'mascota': (BuildContext context) => RegistroPageForm(),
        Principal.routeName: (_) => Principal(),
      },
    );
  }
}
