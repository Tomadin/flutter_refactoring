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

// clase del view model
class CVM extends ChangeNotifier {
  CVM(this.r);
  CarritoRepository r;
  List<Producto> l = [];
  int e = 0; // 0 = cargando, 1 = ok, 2 = error

  // carga
  Future<void> f(bool b) async {
    e = 0;
    notifyListeners();
    try {
      l = await r.obtenerProductos(forzarRecarga: b);
      e = 1;
    } catch (x) {
      e = 2;
    }
    notifyListeners();
  }

  // calcula el total
  String t() {
    double s = 0;
    for (var i = 0; i < l.length; i++) {
      s = s + l[i].precio;
    }
    if (s > 50000) {
      s = s - s * 0.1;
    }
    return '\$ ${s.toStringAsFixed(2)}';
  }

  Future<void> confirmar() async {
    if (l.isNotEmpty) {
      if (e != 0) {
        double s = 0;
        for (var i = 0; i < l.length; i++) {
          s = s + l[i].precio;
        }
        if (s > 50000) {
          s = s * 0.9;
        }
        e = 0;
        notifyListeners();
        try {
          await r.enviarPedido(l, s);
          l = [];
          e = 1;
        } catch (x) {
          e = 2;
        }
        notifyListeners();
        // final viejo = await r.obtenerProductos(forzarRecarga: true);
      }
    }
  }
}

class PantallaCarrito2 extends StatefulWidget {
  const PantallaCarrito2({super.key, required this.r});
  final CarritoRepository r;
  @override
  State<PantallaCarrito2> createState() => _PantallaCarrito2State();
}

class _PantallaCarrito2State extends State<PantallaCarrito2> {
  late CVM vm;

  @override
  void initState() {
    super.initState();
    vm = CVM(widget.r);
    vm.f(false);
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  // arma un item
  Widget _buildItem(Producto p) {
    return ListTile(title: Text(p.nombre), trailing: Text('\$ ${p.precio.toStringAsFixed(2)}'));
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
          if (vm.e == 0) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (vm.e == 2) {
              return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('No se pudo completar la operación.'),
                const SizedBox(height: 12),
                FilledButton(onPressed: () => vm.f(false), child: const Text('Reintentar')),
              ]));
            } else {
              if (vm.l.isEmpty) {
                return const Center(child: Text('No hay productos en el carrito.'));
              }
              return Column(children: [
                Expanded(child: ListView(children: [for (var p in vm.l) _buildItem(p)])),
                Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text('Total: ${vm.t()}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: vm.l.isNotEmpty && vm.e != 0 ? () => vm.confirmar() : null, child: const Text('Confirmar compra')),
                ])),
              ]);
            }
          }
        },
      ),
    );
  }
}
