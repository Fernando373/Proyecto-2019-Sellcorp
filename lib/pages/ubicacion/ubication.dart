import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:little_daffy/pages/ubicacion/bloc/mapa/mapa_bloc.dart';
import 'package:little_daffy/pages/ubicacion/bloc/mi_ubicacion/mi_ubicacion_bloc.dart';
import 'package:little_daffy/pages/ubicacion/bloc/busqueda/busqueda_bloc.dart';

import 'package:little_daffy/pages/ubicacion/pages/acceso_gps_page.dart';
import 'package:little_daffy/pages/ubicacion/pages/loading_page.dart';
import 'package:little_daffy/pages/ubicacion/pages/mapa_page.dart';
import 'package:little_daffy/pages/ubicacion/pages/test_marker_page.dart';

void main() => runApp(Ubicacion());

class Ubicacion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MiUbicacionBloc()),
        BlocProvider(create: (_) => MapaBloc()),
        BlocProvider(create: (_) => BusquedaBloc()),
      ],
      child: MaterialApp(
        title: 'Material App',
        debugShowCheckedModeBanner: false,
        // home: TestMarkerPage(),
        home: LoadingPage(),
        routes: {
          'mapa': (_) => MapaPage(),
          'loading': (_) => LoadingPage(),
          'acceso_gps': (_) => AccesoGpsPage(),
        },
      ),
    );
  }
}
