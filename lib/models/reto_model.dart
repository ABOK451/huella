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
      id: json['id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      categoria: json['categoria'],
      dificultad: json['dificultad'],
      puntos: json['puntos'] ?? 10,
      impactoCo2: (json['impacto_co2'] ?? 0).toDouble(),
      impactoAgua: (json['impacto_agua'] ?? 0).toDouble(),
      instrucciones: json['instrucciones'],
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'categoria': categoria,
      'dificultad': dificultad,
      'puntos': puntos,
      'impacto_co2': impactoCo2,
      'impacto_agua': impactoAgua,
      'instrucciones': instrucciones,
      'activo': activo,
    };
  }

  String get categoriaLabel {
    switch (categoria) {
      case 'agua':
        return 'Agua';
      case 'energia':
        return 'Energía';
      case 'transporte':
        return 'Transporte';
      case 'residuos':
        return 'Residuos';
      case 'consumo':
        return 'Consumo Responsable';
      default:
        return categoria;
    }
  }

  String get dificultadLabel {
    switch (dificultad) {
      case 'facil':
        return 'Fácil';
      case 'medio':
        return 'Medio';
      case 'dificil':
        return 'Difícil';
      default:
        return dificultad;
    }
  }
}

class RetoUsuario {
  final int id;
  final int usuarioId;
  final int retoId;
  final bool completado;
  final DateTime fechaAsignacion;
  final DateTime? fechaCompletado;
  final String? notas;
  final Reto? reto;

  RetoUsuario({
    required this.id,
    required this.usuarioId,
    required this.retoId,
    required this.completado,
    required this.fechaAsignacion,
    this.fechaCompletado,
    this.notas,
    this.reto,
  });

  factory RetoUsuario.fromJson(Map<String, dynamic> json) {
    return RetoUsuario(
      id: json['id'],
      usuarioId: json['usuarioId'],
      retoId: json['retoId'],
      completado: json['completado'] ?? false,
      fechaAsignacion: DateTime.parse(json['fechaAsignacion']),
      fechaCompletado: json['fechaCompletado'] != null
          ? DateTime.parse(json['fechaCompletado'])
          : null,
      notas: json['notas'],
      reto: json['Reto'] != null ? Reto.fromJson(json['Reto']) : null,
    );
  }
}