// =====================================================================
// VERSIÓN "SUCIA" DEL CARRITO — PUNTO DE PARTIDA DEL EJERCICIO 5
//
// Hace lo mismo que la versión de lib/ui/carrito/ (cargar, mostrar,
// aplicar el descuento y confirmar) y FUNCIONA. Pero está escrita a
// propósito rompiendo las recomendaciones del apunte de Código limpio.
//
// En el ejercicio 5 de Refactoring van a transformar el ViewModel CVM,
// paso a paso y con las pruebas en verde, siguiendo el plan de la
// sección 6 del apunte. La pantalla (PantallaCarrito2) solo se toca
// donde el ViewModel lo obliga.
//
// La red de seguridad está en test/caracterizacion_test.dart y en
// test/comparacion_test.dart. Antes de tocar nada: flutter test.
// =====================================================================

import 'package:flutter/material.dart';
import 'package:refactor_ejemplos/ui/core/formato.dart';

import '../data/repositories/carrito_repository.dart';
import '../domain/models/producto.dart';

enum EstadoCarga { cargando, exito, error }

class CarritoViewModel extends ChangeNotifier {
  static const double _montoMinimoParaDescuento = 50000;
  static const double _porcentajeDescuento = 0.1;

  CarritoViewModel(this._repository);
  final CarritoRepository _repository;

  List<Producto> _listaProductos = [];
  EstadoCarga _estado = EstadoCarga.cargando;

  List<Producto> get listaProductos => _listaProductos;
  EstadoCarga get estado => _estado;

  Future<void> f({bool forzarRecarga = false}) async {
    _estado = EstadoCarga.cargando;
    notifyListeners();
    try {
      _listaProductos = await _repository.obtenerProductos(
        forzarRecarga: forzarRecarga,
      );
      _estado = EstadoCarga.exito;
    } catch (x) {
      _estado = EstadoCarga.error;
    }
    notifyListeners();
  }

  double get subtotal => _listaProductos.fold<double>(
    0,
    (suma, producto) => suma + producto.precio,
  );

  double get descuento => subtotal > _montoMinimoParaDescuento
      ? subtotal * _porcentajeDescuento
      : 0;

  double get total => ((subtotal - descuento) * 100).round() / 100;

  String totalTexto() => formatearPrecio(total);

  bool get puedeConfirmar =>
      _listaProductos.isNotEmpty && _estado != EstadoCarga.cargando;

  String formatearPrecio(double precio) => '\$ ${precio.toStringAsFixed(2)}';

  Future<void> confirmarCompra() async {
    if (!puedeConfirmar) return;

    final totalAEnviar = total;
    _estado = EstadoCarga.cargando;
    notifyListeners();
    try {
      await _repository.enviarPedido(_listaProductos, totalAEnviar);
      _listaProductos = [];
      _estado = EstadoCarga.exito;
    } catch (x) {
      _estado = EstadoCarga.error;
    }
    notifyListeners();
  }
}

class PantallaCarrito2 extends StatefulWidget {
  const PantallaCarrito2({super.key, required this.repository});
  final CarritoRepository repository;
  @override
  State<PantallaCarrito2> createState() => _PantallaCarrito2State();
}

class _PantallaCarrito2State extends State<PantallaCarrito2> {
  late CarritoViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = CarritoViewModel(widget.repository);
    vm.f();
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  Widget _buildItem(Producto prod) {
    return ListTile(
      title: Text(prod.nombre),
      trailing: Text(formatearPrecio(prod.precio)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi carrito (versión sucia)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => vm.f(forzarRecarga: true),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: vm,
        builder: (context, child) {
          if (vm.estado == EstadoCarga.cargando) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (vm.estado == EstadoCarga.error) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('No se pudo completar la operación.'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => vm.f(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            } else {
              if (vm.listaProductos.isEmpty) {
                return const Center(
                  child: Text('No hay productos en el carrito.'),
                );
              }
              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        for (var prod in vm.listaProductos) _buildItem(prod),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Total: ${vm.totalTexto()}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: vm.puedeConfirmar
                              ? vm.confirmarCompra
                              : null,
                          child: const Text('Confirmar compra'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
          }
        },
      ),
    );
  }
}
