import 'package:flutter/material.dart';

import 'data/repositories/carrito_repository.dart';
import 'data/services/carrito_service.dart';
// "show" trae solo la pantalla. Así, cuando en el ejercicio 5 el
// ViewModel sucio pase a llamarse CarritoViewModel y tenga su propio
// enum EstadoCarga, no choca con los de la versión limpia.
import 'sucio/carrito_sucio.dart' show PantallaCarrito2;
import 'ui/carrito/view_models/carrito_view_model.dart';
import 'ui/carrito/widgets/carrito_screen.dart';

void main() {
  final repositorio = CarritoRepository(service: CarritoService());
  runApp(RefactorEjemplosApp(repositorio: repositorio));
}

/// App de ejemplo con las dos versiones del carrito.
class RefactorEjemplosApp extends StatelessWidget {
  const RefactorEjemplosApp({super.key, required this.repositorio});

  final CarritoRepository repositorio;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Refactoring',
      theme: ThemeData(colorSchemeSeed: const Color(0xFF006766)),
      home: MenuScreen(repositorio: repositorio),
    );
  }
}

/// Menú para elegir entre la versión de referencia y la que se refactoriza.
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key, required this.repositorio});

  final CarritoRepository repositorio;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Refactoring')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Las dos versiones tienen que funcionar igual antes, durante y '
            'después del refactoring.',
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('Versión de referencia'),
              subtitle: const Text('lib/ui/carrito/'),
              onTap: () => _abrirVersionLimpia(context),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.construction),
              title: const Text('Versión a refactorizar'),
              subtitle: const Text('lib/sucio/carrito_sucio.dart'),
              onTap: () => _abrirVersionSucia(context),
            ),
          ),
        ],
      ),
    );
  }

  void _abrirVersionLimpia(BuildContext context) {
    final viewModel = CarritoViewModel(repositorio: repositorio)..cargar();
    _abrir(context, CarritoScreen(viewModel: viewModel));
  }

  void _abrirVersionSucia(BuildContext context) {
    _abrir(context, PantallaCarrito2(repository: repositorio));
  }

  void _abrir(BuildContext context, Widget pantalla) {
    final ruta = MaterialPageRoute<void>(builder: (_) => pantalla);
    Navigator.of(context).push(ruta);
  }
}
