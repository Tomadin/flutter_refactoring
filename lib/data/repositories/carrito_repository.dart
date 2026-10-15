import '../../domain/models/producto.dart';
import '../services/carrito_service.dart';

/// Cantidad de centavos que tiene un peso.
///
/// La API trabaja en centavos para evitar errores de redondeo con decimales.
const centavosPorPeso = 100;

/// Fuente de verdad de los productos del carrito.
///
/// Convierte los datos crudos de [CarritoService] en objetos [Producto] y
/// los guarda en memoria para no repetir llamadas.
class CarritoRepository {
  CarritoRepository({required CarritoService service}) : _service = service;

  final CarritoService _service;
  List<Producto>? _cache;

  /// Devuelve los productos del carrito.
  ///
  /// La primera vez se los pide al servicio; después devuelve la copia en
  /// memoria, salvo que [forzarRecarga] sea `true`.
  Future<List<Producto>> obtenerProductos({bool forzarRecarga = false}) async {
    final enCache = _cache;
    if (enCache != null && !forzarRecarga) return enCache;

    final crudos = await _service.obtenerItems();
    final productos = crudos.map(_productoDesdeJson).toList();
    _cache = productos;
    return productos;
  }

  /// Envía el pedido con los [productos] y el [total] en pesos.
  ///
  /// Después vacía la copia en memoria, porque ese carrito ya no existe.
  Future<void> enviarPedido(List<Producto> productos, double total) async {
    await _service.enviarPedido({
      'items': [for (final producto in productos) producto.id],
      'total_centavos': (total * centavosPorPeso).round(),
    });
    _cache = null;
  }

  // Privado: es un detalle de cómo el repositorio traduce los datos.
  Producto _productoDesdeJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      precio: (json['precio_centavos'] as int) / centavosPorPeso,
    );
  }
}
