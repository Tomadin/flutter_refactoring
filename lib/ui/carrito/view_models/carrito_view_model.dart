// El ViewModel importa foundation.dart (por ChangeNotifier), no
// material.dart: no conoce widgets (Arquitectura en capas).
import 'package:flutter/foundation.dart';

import '../../../data/repositories/carrito_repository.dart';
import '../../../domain/models/producto.dart';
import '../../core/formato.dart';

/// Los estados posibles de la pantalla del carrito.
enum EstadoCarga { cargando, exito, error }

/// Estado y comandos de la pantalla del carrito.
///
/// Es la versión de REFERENCIA: sirve para comparar al terminar el
/// ejercicio 5. No la copien; el ejercicio es llegar hasta acá paso a paso.
class CarritoViewModel extends ChangeNotifier {
  CarritoViewModel({required CarritoRepository repositorio})
    : _repositorio = repositorio;

  /// Subtotal a partir del cual se aplica el descuento, en pesos.
  static const montoMinimoParaDescuento = 50000.0;

  /// Descuento que se aplica al superar [montoMinimoParaDescuento].
  static const porcentajeDescuento = 0.10;

  final CarritoRepository _repositorio;

  EstadoCarga _estado = EstadoCarga.cargando;
  List<Producto> _productos = [];

  /// En qué estado está la pantalla.
  EstadoCarga get estado => _estado;

  /// Los productos del carrito. La lista no se puede modificar desde afuera.
  List<Producto> get productos => List.unmodifiable(_productos);

  bool get estaCargando => _estado == EstadoCarga.cargando;

  bool get tieneProductos => _productos.isNotEmpty;

  /// Si hay al menos un producto y no se está cargando nada.
  bool get puedeConfirmar => tieneProductos && !estaCargando;

  double get subtotal =>
      _productos.fold<double>(0, (suma, producto) => suma + producto.precio);

  double get descuento {
    if (subtotal <= montoMinimoParaDescuento) return 0;
    return subtotal * porcentajeDescuento;
  }

  double get total => subtotal - descuento;

  String precioTexto(Producto producto) => formatearPrecio(producto.precio);

  String get subtotalTexto => formatearPrecio(subtotal);

  /// El descuento con formato, o `null` si no corresponde descuento.
  String? get descuentoTexto =>
      descuento > 0 ? formatearPrecio(descuento) : null;

  String get totalTexto => formatearPrecio(total);

  /// Carga los productos del carrito.
  ///
  /// Con [forzarRecarga] en `true` ignora la copia en memoria del
  /// repositorio y vuelve a pedirlos al servicio.
  Future<void> cargar({bool forzarRecarga = false}) async {
    _cambiarEstado(EstadoCarga.cargando);
    try {
      _productos = await _repositorio.obtenerProductos(
        forzarRecarga: forzarRecarga,
      );
      _cambiarEstado(EstadoCarga.exito);
    } catch (_) {
      _cambiarEstado(EstadoCarga.error);
    }
  }

  /// Envía el pedido y vacía el carrito.
  ///
  /// No hace nada si [puedeConfirmar] es `false`.
  Future<void> confirmarCompra() async {
    if (!puedeConfirmar) return;

    _cambiarEstado(EstadoCarga.cargando);
    try {
      await _repositorio.enviarPedido(_productos, total);
      _productos = [];
      _cambiarEstado(EstadoCarga.exito);
    } catch (_) {
      _cambiarEstado(EstadoCarga.error);
    }
  }

  void _cambiarEstado(EstadoCarga nuevoEstado) {
    _estado = nuevoEstado;
    notifyListeners();
  }
}
