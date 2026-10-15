/// Simula la API de la tienda.
///
/// Devuelve y recibe los datos tal como viajarían en un JSON: claves con
/// guion bajo y precios en centavos. No guarda nada entre llamadas.
class CarritoService {
  /// Demora simulada de la red.
  static const demora = Duration(milliseconds: 800);

  /// Devuelve los ítems del carrito como mapas sacados de un JSON.
  Future<List<Map<String, dynamic>>> obtenerItems() async {
    await Future<void>.delayed(demora);
    return [
      {'id': 'p1', 'nombre': 'Yerba 1 kg', 'precio_centavos': 450000},
      {'id': 'p2', 'nombre': 'Fideos 500 g', 'precio_centavos': 120000},
      {'id': 'p3', 'nombre': 'Aceite 900 ml', 'precio_centavos': 310050},
      {'id': 'p4', 'nombre': 'Pava eléctrica', 'precio_centavos': 4200000},
    ];
  }

  /// Envía un pedido confirmado.
  ///
  /// El [pedido] lleva los ids de los productos en `items` y el importe en
  /// `total_centavos`.
  Future<void> enviarPedido(Map<String, dynamic> pedido) async {
    // En una app real, acá iría un POST a la API.
    await Future<void>.delayed(demora);
  }
}
