import 'package:flutter/material.dart';
import 'package:little_daffy/pages/adopcion/adopcion_page.dart';
import 'package:little_daffy/pages/organizacion/organizacion_page.dart';
import 'package:little_daffy/pages/registro/registro_page.dart';
import 'package:little_daffy/pages/ubicacion/ubication.dart';


final pageRoutes = <_Route>[
    // _Route( Icons.home, 'Resgistrar Mascota', SlideshowPage()),
    // _Route( Icons.pets, 'Mascotas perdidas', SlideshowPage()),
    _Route( Icons.pets, 'Mascotas en adopcion', AdopcionPage()),
    _Route( Icons.radio_rounded, 'Mapa', Ubicacion()),
    _Route( Icons.pets, 'Registro mascota', RegistroPage()),
    _Route( Icons.home, 'Lista Organizaciones', OrganizacionesPage()),
];
class _Route{

    final IconData icon;
    final String titulo;
    final Widget page;
    _Route(this.icon, this.titulo,this.page);


}