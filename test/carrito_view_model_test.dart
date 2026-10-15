import 'package:flutter_test/flutter_test.dart';
import 'package:refactor_ejemplos/data/repositories/carrito_repository.dart';
import 'package:refactor_ejemplos/ui/carrito/view_models/carrito_view_model.dart';

import 'fakes.dart';

// Pruebas de la versión de REFERENCIA (lib/ui/carrito/).

void main() {
  test('cargar trae los productos y pasa a éxito', () async {
    final viewModel = crearViewModel(ServicioFalso(carritoSinDescuento));

    await viewModel.cargar();

    expect(viewModel.estado, EstadoCarga.exito);
    expect(viewModel.productos.length, 2);
  });

  test('sin descuento si el subtotal no supera el mínimo', () async {
    final viewModel = crearViewModel(ServicioFalso(carritoSinDescuento));

    await viewModel.cargar();

    expect(viewModel.descuento, 0);
    expect(viewModel.descuentoTexto, isNull);
    expect(viewModel.totalTexto, '\$ 5700.00');
  });

  test('10 % de descuento si el subtotal supera el mínimo', () async {
    final viewModel = crearViewModel(ServicioFalso(carritoConDescuento));

    await viewModel.cargar();

    expect(viewModel.descuentoTexto, '\$ 6000.00');
    expect(viewModel.totalTexto, '\$ 54000.00');
  });

  test('confirmarCompra envía el pedido y vacía el carrito', () async {
    final servicio = ServicioFalso(carritoSinDescuento);
    final viewModel = crearViewModel(servicio);
    await viewModel.cargar();

    await viewModel.confirmarCompra();

    expect(servicio.ultimoPedido, {
      'items': ['p1', 'p2'],
      'total_centavos': 570000,
    });
    expect(viewModel.tieneProductos, isFalse);
  });

  test('confirmarCompra no hace nada si el carrito está vacío', () async {
    final servicio = ServicioFalso([]);
    final viewModel = crearViewModel(servicio);
    await viewModel.cargar();

    await viewModel.confirmarCompra();

    expect(servicio.ultimoPedido, isNull);
  });

  test('forzarRecarga vuelve a llamar al servicio', () async {
    final servicio = ServicioFalso(carritoSinDescuento);
    final repositorio = CarritoRepository(service: servicio);

    await repositorio.obtenerProductos();
    await repositorio.obtenerProductos(); // usa la caché
    await repositorio.obtenerProductos(forzarRecarga: true);

    expect(servicio.llamadas, 2);
  });
}
