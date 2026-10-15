import 'package:flutter/material.dart';

/// Una fila del carrito: el nombre del producto y su precio ya formateado.
class ItemCarrito extends StatelessWidget {
  const ItemCarrito({super.key, required this.nombre, required this.precio});

  final String nombre;
  final String precio;

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(nombre), trailing: Text(precio));
  }
}
