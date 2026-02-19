/// Excepción de dominio para errores de API y red.
///
/// Se usa para transformar errores técnicos (HTTP, timeout, parsing)
/// en mensajes controlados para la capa de presentación.
class ApiException implements Exception {
  /// Crea una excepción de API con un mensaje legible para UI.
  ApiException(this.message);

  /// Mensaje de error final.
  final String message;

  @override
  String toString() => message;
}
