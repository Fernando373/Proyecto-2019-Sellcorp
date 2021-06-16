import 'dart:math';
import 'package:flutter/material.dart';

import 'package:little_daffy/pages/registro/widgets/registro_form.dart';
import 'package:little_daffy/utils/app_colors.dart';


class OrganizacionesPage extends StatefulWidget{
  
  @override
  _OrganizacionesPageState createState() => _OrganizacionesPageState();
}

class _OrganizacionesPageState extends State<OrganizacionesPage> {
  
  ScrollController _controller;
  double backgroundHeight = 180.0;

  @override
  void initState() {
    super.initState();

    _controller = ScrollController();
    _controller.addListener(() {
      setState((){
        backgroundHeight = max(
          0,
          180.0 - _controller.offset);
      });
    });
  }

  @override
  Widget build(BuildContext context){


    return Scaffold(
      appBar: AppBar(
        title: Text("ORGANIZACIONES"),
        brightness: Brightness.light,
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient()),
        child: _Lista()
      ),
    );
  } 

  Widget _Lista(){
    return Stack(
      children: <Widget> [
        Container(
          width: double.infinity,
          height: backgroundHeight,
          color: Colors.white
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: ListView(
            controller: _controller,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 10.0, bottom: 16.0),
                child: Text("Encuentra el servicio que buscabas"),
              ),
              _bigItem(),
              _item('Peluditos', 'assets/pages/home/vets/vet_0.png'),
              SizedBox(height: 8.0),
              _item('Vete', 'assets/pages/home/vets/vet_1.png'),
              SizedBox(height: 8.0),
              _item('Peluqueria', 'assets/pages/home/vets/vet_2.png'),
              SizedBox(height: 8.0),
              _item('Peluditos', 'assets/pages/home/vets/vet_0.png'),
              SizedBox(height: 8.0),
              _item('Vete', 'assets/pages/home/vets/vet_1.png'),
              SizedBox(height: 8.0),
              _item('Peluqueria', 'assets/pages/home/vets/vet_2.png'),
              SizedBox(height: 8.0),
              _item('Peluditos', 'assets/pages/home/vets/vet_0.png'),
              SizedBox(height: 8.0),
              _item('Vete', 'assets/pages/home/vets/vet_1.png'),
              SizedBox(height: 8.0),
              _item('Peluqueria', 'assets/pages/home/vets/vet_2.png')
            ],
          ),
        ),
      ]
    );
  }

  Widget _bigItem(){
    
    return Container(
      width: double.infinity,
      height: 130,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/pages/login/as.png')
        ),
        borderRadius: BorderRadius.circular(30.0)
      ),
    );
  }

  Widget _item(String name, String imageName){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: IntrinsicHeight(
              child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 42.0,
                        height: 42.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(21.0),
                          color: AppColors.primary
                        ),
                        child: Center(
                          child: Text(name[0],
                          style: TextStyle(color: Colors.white),)
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Text(name, style: TextStyle(
                        color: AppColors.letras1,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),)     
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Text('Tenemos atencion personalizada y garantizada',
                    style: TextStyle(
                      color: AppColors.letras1,
                      fontSize: 16.0
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text('Los mejores en Bolivia', 
                    style: TextStyle(
                      color: AppColors.letras1,
                      fontSize: 12.0
                    )
                  )
                ],
              ),
            ),
            SizedBox(width: 14.0),
            Container(
              width: 120,
              height: 120,
              child: Image(
                image: AssetImage(imageName),
                fit: BoxFit.cover
              ),
            )
          ]
        ),
      ),
    );
  }
}
