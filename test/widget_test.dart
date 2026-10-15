import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:refactor_ejemplos/ui/carrito/widgets/carrito_screen.dart';
import 'package:refactor_ejemplos/ui/carrito/widgets/item_carrito.dart';
import 'package:refactor_ejemplos/ui/carrito/widgets/resumen_total.dart';

import 'fakes.dart';

// Pruebas de los widgets de la versión de REFERENCIA.

Widget envolver(Widget widget) => MaterialApp(home: Scaffold(body: widget));

void main() {
  testWidgets('ItemCarrito muestra el nombre y el precio', (tester) async {
    await tester.pumpWidget(
      envolver(const ItemCarrito(nombre: 'Yerba', precio: '\$ 4500.00')),
    );

    expect(find.text('Yerba'), findsOneWidget);
    expect(find.text('\$ 4500.00'), findsOneWidget);
  });

  testWidgets('ResumenTotal oculta el descuento si es null', (tester) async {
    await tester.pumpWidget(
      envolver(const ResumenTotal(subtotal: '\$ 10.00', total: '\$ 10.00')),
    );

    expect(find.text('Descuento'), findsNothing);
  });

  testWidgets('sin onConfirmar, el botón está deshabilitado', (tester) async {
    await tester.pumpWidget(
      envolver(const ResumenTotal(subtotal: '\$ 10.00', total: '\$ 10.00')),
    );

    final boton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(boton.onPressed, isNull);
  });

  testWidgets('CarritoScreen muestra los productos y el total', (tester) async {
    final viewModel = crearViewModel(ServicioFalso(carritoConDescuento));
    await viewModel.cargar();

    await tester.pumpWidget(
      MaterialApp(home: CarritoScreen(viewModel: viewModel)),
    );

    expect(find.text('Pava eléctrica'), findsOneWidget);
    expect(find.text('- \$ 6000.00'), findsOneWidget);
    expect(find.text('\$ 54000.00'), findsOneWidget);
  });
}
