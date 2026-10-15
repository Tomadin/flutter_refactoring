# Refactoring — ejemplo ejecutable

Proyecto de los ejercicios del apunte **Refactoring** (ITU · Programación de Aplicaciones para Celulares).

Es el mismo carrito de Código limpio, con el ViewModel sucio `CVM` **sin tocar**, listo para
refactorizarlo paso a paso. Trae dos versiones que funcionan igual:

- **Versión a refactorizar** (`lib/sucio/carrito_sucio.dart`): el ViewModel `CVM` y la pantalla
  `PantallaCarrito2`. Es sobre la que trabajan en el ejercicio 5.
- **Versión de referencia** (`lib/ui/carrito/`): a donde se quiere llegar. Sirve para comparar
  **al final**. No la copien: el ejercicio es el camino, no el resultado.

Al abrir la app aparece un menú para elegir cuál probar.

## Cómo correrlo

Necesitan Flutter 3.32 o posterior (Dart 3.8). Para ver su versión: `flutter --version`.

```
flutter pub get
flutter create . --platforms=android,web   # solo la primera vez
flutter run
```

## Antes de empezar a refactorizar: Git

Cada paso del refactoring se guarda en un commit (apunte, sección 3). Dentro de la carpeta:

```
git init
git add .
git commit -m "Punto de partida"
```

Después, en cada paso: un cambio chico, `flutter test` y `git commit -am "Qué hice"`.
Si algo se rompe y no ven por qué: `git restore .` y vuelven al último paso que andaba.

## Las pruebas (16)

| Archivo | Qué prueba | ¿Se toca en el ejercicio 5? |
|---|---|---|
| `test/caracterizacion_test.dart` | Lo que `CVM` y `PantallaCarrito2` hacen **hoy**: qué se envía al confirmar, el carrito vacío, el error y el total en pantalla. | Sí: las llamadas se actualizan solas al renombrar, y en el paso 6 se agrega la prueba del centavo. |
| `test/comparacion_test.dart` | Que las dos versiones **muestran** el mismo total. | Solo se actualiza sola al renombrar. |
| `test/carrito_view_model_test.dart` | La versión de referencia. | No. |
| `test/widget_test.dart` | Los widgets de la versión de referencia. | No. |

**Regla de oro: nunca hagan un commit con pruebas en rojo.**

## Sobre los nombres

Al terminar el ejercicio 5, `CVM` va a llamarse `CarritoViewModel` y va a tener su propio enum
`EstadoCarga`, igual que la versión de referencia. No hay choque de nombres porque los archivos
que importan las dos versiones lo hacen con prefijo (`as sucio` en `comparacion_test.dart`) o
trayendo solo la pantalla (`show PantallaCarrito2` en `main.dart`).

## Herramientas

```
dart format .        # formatea el código
flutter analyze      # revisa el código (al principio, los avisos están todos en lib/sucio/)
dart fix --apply     # correcciones automáticas (en un commit aparte)
flutter test         # la red de seguridad
```
# flutter_refactoring
