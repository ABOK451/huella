import 'package:flutter/material.dart';
import 'package:huella/models/reto_model.dart';
import 'package:huella/providers/retos_provider.dart';
import 'reto_detalle_screen.dart';

class RetosScreen extends StatefulWidget {
  const RetosScreen({Key? key}) : super(key: key);

  @override
  State<RetosScreen> createState() => _RetosScreenState();
}

class _RetosScreenState extends State<RetosScreen> {
  final RetosService _retosService = RetosService();
  RetoUsuario? _retoDiario;
  List<Reto> _todosLosRetos = [];
  bool _isLoading = true;
  String _selectedCategoria = 'todos';

  final List<Map<String, dynamic>> _categorias = [
    {'id': 'todos', 'nombre': 'Todos', 'icon': Icons.grid_view},
    {'id': 'agua', 'nombre': 'Agua', 'icon': Icons.water_drop},
    {'id': 'energia', 'nombre': 'Energía', 'icon': Icons.bolt},
    {'id': 'transporte', 'nombre': 'Transporte', 'icon': Icons.directions_bike},
    {'id': 'residuos', 'nombre': 'Residuos', 'icon': Icons.recycling},
    {'id': 'consumo', 'nombre': 'Consumo', 'icon': Icons.shopping_bag},
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      final retoDiario = await _retosService.obtenerRetoDiario();
      final retos = await _retosService.obtenerRetos();
      
      setState(() {
        _retoDiario = retoDiario;
        _todosLosRetos = retos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  List<Reto> get _retosFiltrados {
    if (_selectedCategoria == 'todos') {
      return _todosLosRetos;
    }
    return _todosLosRetos.where((r) => r.categoria == _selectedCategoria).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retos Ecológicos'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarDatos,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reto del día
                    if (_retoDiario != null) _buildRetoDiario(),
                    
                    const SizedBox(height: 16),
                    
                    // Categorías
                    _buildCategorias(),
                    
                    const SizedBox(height: 16),
                    
                    // Lista de retos
                    _buildListaRetos(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildRetoDiario() {
    final reto = _retoDiario!.reto;
    if (reto == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.green[700]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _verDetalleReto(_retoDiario!),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.wb_sunny, color: Colors.white, size: 28),
                    const SizedBox(width: 8),
                    const Text(
                      'Reto del Día',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  reto.titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  reto.descripcion,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildChip(reto.categoriaLabel, Icons.category),
                    const SizedBox(width: 8),
                    _buildChip('${reto.puntos} pts', Icons.stars),
                    const Spacer(),
                    if (_retoDiario!.completado)
                      const Icon(Icons.check_circle, color: Colors.white, size: 32)
                    else
                      ElevatedButton(
                        onPressed: () => _completarReto(_retoDiario!),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.green[700],
                        ),
                        child: const Text('Completar'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorias() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categorias.length,
        itemBuilder: (context, index) {
          final categoria = _categorias[index];
          final isSelected = _selectedCategoria == categoria['id'];
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoria = categoria['id'];
              });
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.green[700] : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    categoria['icon'],
                    color: isSelected ? Colors.white : Colors.grey[700],
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    categoria['nombre'],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListaRetos() {
    if (_retosFiltrados.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No hay retos disponibles en esta categoría'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _retosFiltrados.length,
      itemBuilder: (context, index) {
        final reto = _retosFiltrados[index];
        return _buildRetoCard(reto);
      },
    );
  }

  Widget _buildRetoCard(Reto reto) {
    Color categoriaColor = _getCategoriaColor(reto.categoria);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _verDetalleRetoDirecto(reto),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: categoriaColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getCategoriaIcon(reto.categoria),
                  color: categoriaColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reto.titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reto.descripcion,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildSmallChip(
                          reto.dificultadLabel,
                          _getDificultadColor(reto.dificultad),
                        ),
                        const SizedBox(width: 8),
                        _buildSmallChip(
                          '${reto.puntos} pts',
                          Colors.amber,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getCategoriaColor(String categoria) {
    switch (categoria) {
      case 'agua':
        return Colors.blue;
      case 'energia':
        return Colors.orange;
      case 'transporte':
        return Colors.purple;
      case 'residuos':
        return Colors.brown;
      case 'consumo':
        return Colors.teal;
      default:
        return Colors.green;
    }
  }

  IconData _getCategoriaIcon(String categoria) {
    switch (categoria) {
      case 'agua':
        return Icons.water_drop;
      case 'energia':
        return Icons.bolt;
      case 'transporte':
        return Icons.directions_bike;
      case 'residuos':
        return Icons.recycling;
      case 'consumo':
        return Icons.shopping_bag;
      default:
        return Icons.eco;
    }
  }

  Color _getDificultadColor(String dificultad) {
    switch (dificultad) {
      case 'facil':
        return Colors.green;
      case 'medio':
        return Colors.orange;
      case 'dificil':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _verDetalleReto(RetoUsuario retoUsuario) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RetoDetalleScreen(retoUsuario: retoUsuario),
      ),
    ).then((_) => _cargarDatos());
  }

  void _verDetalleRetoDirecto(Reto reto) {
    // Aquí podrías crear un RetoUsuario temporal o mostrar solo info del reto
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(reto.titulo),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(reto.descripcion),
              const SizedBox(height: 16),
              if (reto.instrucciones != null) ...[
                const Text(
                  'Instrucciones:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(reto.instrucciones!),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  const Icon(Icons.eco, size: 20, color: Colors.green),
                  const SizedBox(width: 8),
                  Text('${reto.impactoCo2} kg CO₂ ahorrado'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.water_drop, size: 20, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text('${reto.impactoAgua} L agua ahorrada'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _completarReto(RetoUsuario retoUsuario) async {
    try {
      final exito = await _retosService.completarReto(retoUsuario.id);
      
      if (exito && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Reto completado! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
        _cargarDatos();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}