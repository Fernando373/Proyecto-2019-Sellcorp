
import 'package:flutter/material.dart';
import 'package:little_daffy/models/mascota_model.dart';
import 'package:little_daffy/pages/registro/widgets/registro_form.dart';
import 'package:little_daffy/providers/mascotas_provider.dart';
import 'package:little_daffy/utils/app_colors.dart';


class RegistroPage extends StatelessWidget{

  
  final mascotasProvider = new MascotasProvider();

  @override
  Widget build(BuildContext context){


    return Scaffold(
      appBar: AppBar(
        title: Text("LITTLE DAFFY"),
        brightness: Brightness.light,
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient()),
        child: _crearListado()
      ),
      floatingActionButton: _crearBoton(context),
    );
  } 


_crearBoton(BuildContext context){
  return FloatingActionButton(
    backgroundColor: AppColors.primary,
    child: Icon(Icons.add),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RegistroPageForm()),
      );
    }
  );
}

Widget _crearListado() {

  return FutureBuilder(
    future: mascotasProvider.cargarMascotas(),
    builder: (BuildContext context, AsyncSnapshot<List<MascotaModel>> snapshot){
      if(snapshot.hasData){

        final mascotas = snapshot.data;
        return ListView.builder(
          itemCount: mascotas.length,
          itemBuilder: (context, i) => _crearItem(context, mascotas [i]),
        );
      }else{
        return Center(child: CircularProgressIndicator(),);
      }
    }
  );
}

  Widget _crearItem(BuildContext context, MascotaModel mascota){
    return Dismissible(
      key: UniqueKey(),
      background: Container(
        color: AppColors.verde.withOpacity(0.8),
      ),
      onDismissed: (direccion){
        mascotasProvider.borrarMascota(mascota.id); 
      },
      child: ListTile(
        title: Text('${mascota.nombre} - ${mascota.edad}'),
        subtitle: Text(mascota.id),
        onTap: () => Navigator.pushNamed(context, 'mascota', arguments: mascota),
      ),
    );
  }

}
