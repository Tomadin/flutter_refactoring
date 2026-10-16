import 'package:flutter_test/flutter_test.dart';
import 'package:refactor_ejemplos/data/repositories/carrito_repository.dart';
// El prefijo "sucio." evita choques de nombres: al terminar el
// ejercicio 5, las dos versiones van a tener una clase CarritoViewModel.
import 'package:refactor_ejemplos/sucio/carrito_sucio.dart' as sucio;
import 'package:refactor_ejemplos/ui/carrito/view_models/carrito_view_model.dart';

import 'fakes.dart';

// Comprueba que la versión a refactorizar y la de referencia MUESTRAN el
// mismo total. Ojo: solo mira el total que se muestra (apunte, sección 3).
void main() {
  for (final (nombre, items) in [
    ('sin descuento', carritoSinDescuento),
    ('con descuento', carritoConDescuento),
  ]) {
    test('las dos versiones calculan el mismo total ($nombre)', () async {
      final repositorio = CarritoRepository(service: ServicioFalso(items));
      final limpio = CarritoViewModel(repositorio: repositorio);
      final vmSucio = sucio.CarritoViewModel(repositorio);

      await limpio.cargar();
      await vmSucio.f();

      expect(vmSucio.totalTexto(), limpio.totalTexto);
    });
  }
}
