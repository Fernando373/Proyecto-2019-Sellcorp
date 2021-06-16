import 'dart:convert';

MascotaModel mascotaModelFromJson(String str) => MascotaModel.fromJson(json.decode(str));

String mascotaModelToJson(MascotaModel data) => json.encode(data.toJson());

class MascotaModel {

    String id;
    String nombre;
    double edad;
    bool estado;
    String fotoUrl;

    MascotaModel({
        this.id,
        this.nombre = '',
        this.edad = 0.0,
        this.estado = true,
        this.fotoUrl,
    });

    

    factory MascotaModel.fromJson(Map<String, dynamic> json) => new MascotaModel(
        id: json["id"],
        nombre: json["nombre"],
        edad: json["edad"],
        estado: json["estado"],
        fotoUrl: json["fotoUrl"],
    );

    Map<String, dynamic> toJson() => {
        //"id": id,
        "nombre": nombre,
        "edad": edad,
        "estado": estado,
        "fotoUrl": fotoUrl,
    };
}
