import 'package:refactor_ejemplos/data/repositories/carrito_repository.dart';
import 'package:refactor_ejemplos/data/services/carrito_service.dart';
import 'package:refactor_ejemplos/ui/carrito/view_models/carrito_view_model.dart';

// Piezas falsas para las pruebas. Funcionan porque cada clase recibe sus
// dependencias por constructor (Arquitectura en capas).

/// Servicio que devuelve datos fijos al instante, sin demora ni red.
class ServicioFalso implements CarritoService {
  ServicioFalso(this.items);

  final List<Map<String, dynamic>> items;

  /// Cuántas veces se pidieron los ítems (para probar la caché).
  int llamadas = 0;

  /// El último pedido enviado, o `null` si no se envió ninguno.
  Map<String, dynamic>? ultimoPedido;

  @override
  Future<List<Map<String, dynamic>>> obtenerItems() async {
    llamadas++;
    return items;
  }

  @override
  Future<void> enviarPedido(Map<String, dynamic> pedido) async {
    ultimoPedido = pedido;
  }
}

/// Servicio que siempre falla, como si no hubiera conexión.
class ServicioQueFalla implements CarritoService {
  @override
  Future<List<Map<String, dynamic>>> obtenerItems() async {
    throw Exception('Sin conexión');
  }

  @override
  Future<void> enviarPedido(Map<String, dynamic> pedido) async {
    throw Exception('Sin conexión');
  }
}

// Datos de prueba, en el mismo formato que devuelve la API.
const yerba = {'id': 'p1', 'nombre': 'Yerba 1 kg', 'precio_centavos': 450000};
const fideos = {
  'id': 'p2',
  'nombre': 'Fideos 500 g',
  'precio_centavos': 120000,
};
const pava = {
  'id': 'p4',
  'nombre': 'Pava eléctrica',
  'precio_centavos': 6000000,
};

const auris = {
  'id': 'p7',
  'nombre': 'Auriculares',
  'precio_centavos': 5000005,
};

/// Carrito de $ 5700: no llega al mínimo para el descuento.
const carritoSinDescuento = [yerba, fideos];

/// Carrito de $ 60000: tiene 10 % de descuento.
const carritoConDescuento = [pava];

/// Carrito con centavos
const carritoCentavo = [auris];

/// Arma un ViewModel de referencia conectado a un [ServicioFalso].
CarritoViewModel crearViewModel(ServicioFalso servicio) {
  final repositorio = CarritoRepository(service: servicio);
  return CarritoViewModel(repositorio: repositorio);
}
