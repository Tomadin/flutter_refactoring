import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:refactor_ejemplos/data/repositories/carrito_repository.dart';
import 'package:refactor_ejemplos/sucio/carrito_sucio.dart';

import 'fakes.dart';

// =====================================================================
// PRUEBAS DE CARACTERIZACIÓN de la versión a refactorizar
// (apunte de Refactoring, sección 3).
//
// No dicen si CVM está bien o mal: fijan lo que hace HOY, para que
// cualquier cambio de comportamiento durante el refactoring se note.
//
// Todas miran lo que se ve desde AFUERA: lo que se envía al servicio y
// lo que aparece en pantalla. Ninguna pregunta por el int "e", que va a
// desaparecer en el paso 7 del plan.
// =====================================================================

void main() {
  group('CVM', () {
    test('confirmar envía el pedido con el descuento aplicado', () async {
      final servicio = ServicioFalso(carritoConDescuento); // $ 60000
      final vm = CarritoViewModel(CarritoRepository(service: servicio));
      await vm.f();

      await vm.confirmarCompra();

      // Lo que le llegó al servicio: 60000 - 10 % = 54000 pesos.
      expect(servicio.ultimoPedido, {
        'items': ['p4'],
        'total_centavos': 5400000,
      });
      // Y después de confirmar, el carrito queda vacío.
      expect(vm.totalTexto(), '\$ 0.00');
    });

    test('confirmar no hace nada si el carrito está vacío', () async {
      final servicio = ServicioFalso([]);
      final vm = CarritoViewModel(CarritoRepository(service: servicio));
      await vm.f();

      await vm.confirmarCompra();

      expect(servicio.ultimoPedido, isNull);
    });

    test('f(true) vuelve a pedir los productos al servicio', () async {
      final servicio = ServicioFalso(
        carritoSinDescuento,
      ); // comienza con llamadas = 0
      final vm = CarritoViewModel(CarritoRepository(service: servicio));

      await vm.f(); //llamadas = 1

      await vm.f(forzarRecarga: true); //llamadas = 2

      expect(servicio.llamadas, 2);
    });
  });

  // Las pruebas de pantalla cubren lo que las de arriba no ven: los tres
  // estados (cargando, error, éxito) y la conexión con los botones.
  group('PantallaCarrito2', () {
    testWidgets('muestra el error si el servicio falla', (tester) async {
      final repositorio = CarritoRepository(service: ServicioQueFalla());

      await tester.pumpWidget(
        MaterialApp(home: PantallaCarrito2(repository: repositorio)),
      );
      await tester.pumpAndSettle(); // espera a que termine de cargar

      expect(find.text('No se pudo completar la operación.'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    test(
      'lo que muestra la pantalla es lo que se envía (prueba del centavo)',
      () async {
        final servicio = ServicioFalso(
          carritoCentavo,
        ); // un producto de $ 50000.05
        final vm = CarritoViewModel(CarritoRepository(service: servicio));
        await vm.f();

        final textoTotal = vm.totalTexto(); // '$ 45000.04' o '$ 45000.05'
        final centavosMostrados =
            (double.parse(textoTotal.replaceAll('\$ ', '')) * 100).round();

        await vm.confirmarCompra();

        expect(servicio.ultimoPedido!['total_centavos'], centavosMostrados);
      },
    );

    testWidgets('muestra el total y al confirmar vacía el carrito', (
      tester,
    ) async {
      final servicio = ServicioFalso(carritoConDescuento);
      final repositorio = CarritoRepository(service: servicio);

      await tester.pumpWidget(
        MaterialApp(home: PantallaCarrito2(repository: repositorio)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pava eléctrica'), findsOneWidget);
      expect(find.text('Total: \$ 54000.00'), findsOneWidget);

      await tester.tap(find.text('Confirmar compra'));
      await tester.pumpAndSettle();

      expect(find.text('No hay productos en el carrito.'), findsOneWidget);
      expect(servicio.ultimoPedido, isNotNull);
    });
  });
}
