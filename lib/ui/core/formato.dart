// Funciones de formato que usan varias pantallas. Viven en ui/core/ para
// que nadie tenga que copiarlas.

/// Da formato de precio en pesos a un [monto], por ejemplo `$ 4500.00`.
String formatearPrecio(double monto) => '\$ ${monto.toStringAsFixed(2)}';
