class Empresa{
  final int? id;
  final String nombre;
  final String ruc;
  final String? direccion;
  final String? rubro;
  final bool esactivo;

  Empresa({
    this.id, 
    required this.nombre, 
    required this.ruc, 
    this.direccion, 
    this.rubro, 
    this.esactivo = true
    });

  factory Empresa.fromJson(Map<String, dynamic> json) => Empresa(
    id:json['id'],
    nombre:json['nombre'],
    ruc:json['ruc'],
    direccion:json['direccion'],
    rubro:json['rubro'],
    esactivo:json['esactivo'] ?? true,
  );

  Map<String, dynamic> toJson() => {
    "nombre": nombre,
    "ruc": ruc,
    "direccion": direccion,
    "rubro": rubro,
    "esactivo" : esactivo
  };

}