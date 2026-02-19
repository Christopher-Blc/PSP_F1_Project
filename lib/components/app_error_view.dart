import 'package:flutter/material.dart';

/// Componente legado de error.
///
/// Se mantiene para compatibilidad temporal en el proyecto.
class AppErrorView extends StatelessWidget {
  /// Crea una vista de error con botón de reintento.
  const AppErrorView({super.key, required this.message, required this.onRetry});

  /// Mensaje a mostrar al usuario.
  final String message;

  /// Callback para repetir la operación fallida.
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: <Widget>[
        const SizedBox(height: 120),
        const Icon(Icons.error_outline, size: 64),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(message, textAlign: TextAlign.center),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: onRetry,
            child: const Text('Try again'),
          ),
        ),
      ],
    );
  }
}
