import 'package:flutter/material.dart';

/// Subtotal, descuento, total y el botón para confirmar la compra.
///
/// Avisa que tocaron el botón con el callback [onConfirmar]. Si
/// [onConfirmar] es `null`, el botón aparece deshabilitado.
class ResumenTotal extends StatelessWidget {
  const ResumenTotal({
    super.key,
    required this.subtotal,
    required this.total,
    this.descuento,
    this.onConfirmar,
  });

  final String subtotal;
  final String total;

  /// El descuento con formato, o `null` para no mostrar esa fila.
  final String? descuento;

  final VoidCallback? onConfirmar;

  @override
  Widget build(BuildContext context) {
    final descuento = this.descuento;
    final estiloTotal = Theme.of(context).textTheme.titleMedium;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FilaImporte(etiqueta: 'Subtotal', importe: subtotal),
          if (descuento != null)
            _FilaImporte(etiqueta: 'Descuento', importe: '- $descuento'),
          const Divider(),
          _FilaImporte(etiqueta: 'Total', importe: total, estilo: estiloTotal),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onConfirmar,
            child: const Text('Confirmar compra'),
          ),
        ],
      ),
    );
  }
}

class _FilaImporte extends StatelessWidget {
  const _FilaImporte({
    required this.etiqueta,
    required this.importe,
    this.estilo,
  });

  final String etiqueta;
  final String importe;
  final TextStyle? estilo;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(etiqueta, style: estilo), Text(importe, style: estilo)],
    );
  }
}
