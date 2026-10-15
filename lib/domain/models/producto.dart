/// Un producto del carrito, tal como lo entiende la app.
///
/// Es un modelo de dominio: no sabe de dónde vienen los datos.
class Producto {
  const Producto({
    required this.id,
    required this.nombre,
    required this.precio,
  });

  final String id;
  final String nombre;

  /// Precio unitario, en pesos.
  final double precio;
}
