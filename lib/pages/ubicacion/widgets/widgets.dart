import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:little_daffy/pages/ubicacion/helpers/helpers.dart';

import 'package:little_daffy/pages/ubicacion/bloc/busqueda/busqueda_bloc.dart';
import 'package:little_daffy/pages/ubicacion/bloc/mapa/mapa_bloc.dart';
import 'package:little_daffy/pages/ubicacion/bloc/mi_ubicacion/mi_ubicacion_bloc.dart';
import 'package:polyline/polyline.dart' as Poly;

import 'package:little_daffy/pages/ubicacion/services/traffic_service.dart';

import 'package:little_daffy/pages/ubicacion/models/search_result.dart';
import 'package:little_daffy/pages/ubicacion/search/search_destination.dart';

part 'btn_mi_ruta.dart';
part 'btn_ubicacion.dart';
part 'btn_seguir_ubicacion.dart';
part 'marcador_manual.dart';
part 'searchbar.dart';
