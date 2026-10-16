import 'package:flutter/material.dart';

import '../view_models/carrito_view_model.dart';
import 'item_carrito.dart';
import 'resumen_total.dart';

/// Pantalla del carrito: muestra los productos y permite confirmar la compra.
class CarritoScreen extends StatelessWidget {
  const CarritoScreen({super.key, required this.viewModel});

  final CarritoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi carrito'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () => viewModel.cargar(forzarRecarga: true),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          return switch (viewModel.estado) {
            EstadoCarga.cargando => const _VistaCargando(),
            EstadoCarga.error => _VistaError(onReintentar: viewModel.cargar),
            EstadoCarga.exito => _ContenidoCarrito(viewModel: viewModel),
          };
        },
      ),
    );
  }
}

class _VistaCargando extends StatelessWidget {
  const _VistaCargando();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _VistaError extends StatelessWidget {
  const _VistaError({required this.onReintentar});

  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('No se pudo completar la operación.'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onReintentar,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class _ContenidoCarrito extends StatelessWidget {
  const _ContenidoCarrito({required this.viewModel});

  final CarritoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    if (!viewModel.tieneProductos) {
      return const Center(child: Text('No hay productos en el carrito.'));
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              for (final producto in viewModel.productos)
                ItemCarrito(
                  nombre: producto.nombre,
                  precio: viewModel.precioTexto(producto),
                ),
            ],
          ),
        ),
        ResumenTotal(
          subtotal: viewModel.subtotalTexto,
          descuento: viewModel.descuentoTexto,
          total: viewModel.totalTexto,
          onConfirmar: viewModel.puedeConfirmar
              ? viewModel.confirmarCompra
              : null,
        ),
      ],
    );
  }
}
