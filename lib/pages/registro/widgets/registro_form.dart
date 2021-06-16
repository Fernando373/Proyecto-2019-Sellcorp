import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:little_daffy/models/mascota_model.dart';
import 'package:little_daffy/providers/mascotas_provider.dart';
import 'package:little_daffy/utils/app_colors.dart';
import 'package:little_daffy/utils/numero.dart' as numero;
import 'package:little_daffy/widgets/rounded_button.dart';


class RegistroPageForm extends StatefulWidget{

  @override
  _RegistroPageFormState createState() => _RegistroPageFormState();
}

class _RegistroPageFormState extends State<RegistroPageForm> {

  final formKey         = GlobalKey<FormState>();
  final scaffoldKey     = GlobalKey<ScaffoldState>();
  final mascotaProvider = new MascotasProvider();

  MascotaModel mascota = new MascotaModel();
  bool _guardando = false;
  File foto;

  @override
  Widget build(BuildContext context){

    final MascotaModel masData = ModalRoute.of(context).settings.arguments;
    if (masData != null){
      mascota = masData;
    }
    
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Little Daffy - Registro Mascota"),
        brightness: Brightness.light,
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.photo_size_select_actual), 
            onPressed: _seleccionarFoto,
          ),
          IconButton(
            icon: Icon(Icons.camera_alt), 
            onPressed: _tomarFoto,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(gradient: bgGradient()),
          padding: EdgeInsets.all(15.0),
          child: Form(
            key: formKey,
            child: Column(
            children: <Widget>[
              _mostrarFoto(),
              _crearNombre(),
              _crearEdad(),
              _crearEstado(),
              SizedBox(
                
              ),
              _crearBoton(context),
            ]
          ),),
        ),
      ),
    );
  }

  Widget _crearNombre() {

    return TextFormField(
      initialValue: mascota.nombre,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: 'Nombre mascota'
      ),
      onSaved: (value) => mascota.nombre = value,
      validator: (value) {
        if(value.length < 1){
          return 'Ingrese nombre de la mascota';
        }else{
          return null;
        }
      },
    );

  }

  Widget _crearEdad() {

    return TextFormField(
      initialValue: mascota.edad.toString(),
      keyboardType: TextInputType.numberWithOptions(decimal: false),
      decoration: InputDecoration(
        labelText: 'Edad mascota (años)'
      ),
      onSaved: (value) => mascota.edad = double.parse(value),
      validator: (value){
        if (numero.isNumeric(value)){
          return null;
        }else{
          return 'Solo numeros';
        }
      },
    );
    
  }

  Widget _crearEstado(){
    return SwitchListTile(value: mascota.estado,
     title: Text('Adopcion / Perdida'),
     activeColor: AppColors.primary,
     onChanged: (value)=> setState((){
       mascota.estado = value;
     }),
    );
  }

  Widget _crearBoton(context) {

    return RoundedButton(
        label: "Guardar",
      //backgroundColor: AppColors.letras,
      onPressed: (_guardando) ? null: _submit,
    );
  }

  void _submit(){

    if(!formKey.currentState.validate()) return;
    formKey.currentState.save();
    
    
    setState((){_guardando = true; } );

    if( mascota.id == null ){
      mascotaProvider.crearMascota(mascota);
    }else{
      mascotaProvider.editarMascota(mascota);
    }

    mostrarSnackbar('Registro guardado');
    Navigator.pop(context);

  }

  void mostrarSnackbar(String mensaje){
    final snackbar = SnackBar(
      backgroundColor: AppColors.primary,
      content: Text(mensaje),
      duration: Duration(milliseconds: 1500)
    );

    scaffoldKey.currentState.showSnackBar(snackbar);
  }


  Widget _mostrarFoto(){
    if( mascota.fotoUrl != null){
      return Container();
    }else {
      return Image(
        image: AssetImage( foto?.path ?? 'assets/pages/registro/no-image.png'),
        height: 300.0,
        fit: BoxFit.cover
      );
    }
  }

  _seleccionarFoto() async{

    _procesarImagen(ImageSource.gallery);
  }


  _tomarFoto() async {
    
    _procesarImagen(ImageSource.camera);
  }

  _procesarImagen(ImageSource origen) async {
    
    foto = await ImagePicker.pickImage(
      source : origen
    );
    if(foto != null){

    }
    setState((){});
  }


}

  bgGradient() {
    return LinearGradient(colors: [
      Color(0xffffffff).withOpacity(0.9),
      AppColors.verde.withOpacity(0.7)
    ], begin: Alignment.center , end: Alignment.bottomCenter);
  }