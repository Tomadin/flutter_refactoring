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

import '../data/repositories/carrito_repository.dart';
import '../domain/models/producto.dart';

enum EstadoCarga {
  cargando,
  exito,
  error,
}

// clase del view model
class CarritoViewModel extends ChangeNotifier {
  CarritoViewModel(this.repository);
  CarritoRepository repository;
  List<Producto> listaProductos = [];
  EstadoCarga estado = EstadoCarga.cargando; // 0 = cargando, 1 = ok, 2 = error

  // carga
  Future<void> f(bool b) async {
    estado = EstadoCarga.cargando;
    notifyListeners();
    try {
      listaProductos = await repository.obtenerProductos(forzarRecarga: b);
      estado = EstadoCarga.exito;
    } catch (x) {
      estado = EstadoCarga.error;
    }
    notifyListeners();
  }

  // calcula el total
  String totalTexto() {
    double subtotal = 0;
    for (var i = 0; i < listaProductos.length; i++) {
      subtotal = subtotal + listaProductos[i].precio;
    }
    if (subtotal > 50000) {
      subtotal = subtotal - subtotal * 0.1;
    }
    return '\$ ${subtotal.toStringAsFixed(2)}';
  }

  Future<void> confirmar() async {
    if (listaProductos.isNotEmpty) {
      if (estado != 0) {
        double subtotal = 0;
        for (var i = 0; i < listaProductos.length; i++) {
          subtotal = subtotal + listaProductos[i].precio;
        }
        if (subtotal > 50000) {
          subtotal = subtotal * 0.9;
        }
        estado = EstadoCarga.cargando;
        notifyListeners();
        try {
          await repository.enviarPedido(listaProductos, subtotal);
          listaProductos = [];
          estado = EstadoCarga.exito;
        } catch (x) {
          estado = EstadoCarga.error;
        }
        notifyListeners();
        // final viejo = await r.obtenerProductos(forzarRecarga: true);
      }
    }
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
    vm.f(false);
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  // arma un item
  Widget _buildItem(Producto prod) {
    return ListTile(title: Text(prod.nombre), trailing: Text('\$ ${prod.precio.toStringAsFixed(2)}'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi carrito (versión sucia)'), actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: () => vm.f(true)),
      ]),
      body: ListenableBuilder(
        listenable: vm,
        builder: (context, child) {
          if (vm.estado == EstadoCarga.cargando) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (vm.estado == EstadoCarga.error) {
              return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('No se pudo completar la operación.'),
                const SizedBox(height: 12),
                FilledButton(onPressed: () => vm.f(false), child: const Text('Reintentar')),
              ]));
            } else {
              if (vm.listaProductos.isEmpty) {
                return const Center(child: Text('No hay productos en el carrito.'));
              }
              return Column(children: [
                Expanded(child: ListView(children: [for (var prod in vm.listaProductos) _buildItem(prod)])),
                Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text('Total: ${vm.totalTexto()}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: vm.listaProductos.isNotEmpty && vm.estado != EstadoCarga.cargando ? () => vm.confirmar() : null, child: const Text('Confirmar compra')),
                ])),
              ]);
            }
          }
        },
      ),
    );
  }
}
