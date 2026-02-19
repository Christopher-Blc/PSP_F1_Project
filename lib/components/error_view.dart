import 'package:flutter/material.dart';

/// Vista reutilizable para mostrar errores de carga de datos.
class ErrorView extends StatelessWidget {
  /// Crea una vista de error con botón de reintento.
  const ErrorView({super.key, required this.message, required this.onRetry});

  /// Mensaje a mostrar al usuario.
  final String message;

  /// Callback para volver a intentar la operación fallida.
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: <Widget>[
        const SizedBox(height: 120),
        Icon(Icons.error_outline, size: 64, color: colors.error),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
            ),
            child: const Text('Reintentar'),
          ),
        ),
      ],
    );
  }
}
