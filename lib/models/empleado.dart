class Empleado {
  int? id;
  String nombre;
  String cargo;
  int empresaId;

  Empleado({
    this.id,
    required this.nombre,
    required this.cargo,
    required this.empresaId,
  });

  factory Empleado.fromJson(Map<String, dynamic> json) {
    return Empleado(
      id: json['id'],
      nombre: json['nombre'],
      cargo: json['cargo'],
      empresaId: json['empresaId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'cargo': cargo,
    'empresaId': empresaId,
  };
}