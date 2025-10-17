class Reto {
  final int id;
  final String titulo;
  final String descripcion;
  final String categoria;
  final String dificultad;
  final int puntos;
  final double impactoCo2;
  final double impactoAgua;
  final String? instrucciones;
  final bool activo;

  Reto({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.dificultad,
    required this.puntos,
    required this.impactoCo2,
    required this.impactoAgua,
    this.instrucciones,
    this.activo = true,
  });

  factory Reto.fromJson(Map<String, dynamic> json) {
    return Reto(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      categoria: json['categoria'] ?? '',
      dificultad: json['dificultad'] ?? 'facil',
      puntos: json['puntos'] is int ? json['puntos'] : int.tryParse(json['puntos'].toString()) ?? 10,
      impactoCo2: _parseDouble(json['impacto_co2']),
      impactoAgua: _parseDouble(json['impacto_agua']),
      instrucciones: json['instrucciones'],
      activo: json['activo'] == true || json['activo'] == 1,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}

class RetoUsuario {
  final int id;
  final Reto reto;
  final DateTime completadoEn;
  final String estado;

  RetoUsuario({
    required this.id,
    required this.reto,
    required this.completadoEn,
    required this.estado,
  });

  factory RetoUsuario.fromJson(Map<String, dynamic> json) {
    return RetoUsuario(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      reto: Reto.fromJson(json['reto'] ?? {}),
      completadoEn: DateTime.parse(json['completadoEn'] ?? DateTime.now().toIso8601String()),
      estado: json['estado'] ?? 'pendiente',
    );
  }
}
