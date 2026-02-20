import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

/// Cliente HTTP para consumir la API de Jolpi.
///
/// Todas las operaciones de red son asíncronas para no bloquear
/// el hilo principal de la interfaz.
class JolpiApiClient {
  /// Crea el cliente de API.
  ///
  /// [client] permite inyección para tests.
  /// [baseUrl] permite sobrescribir la URL base por entorno.
  JolpiApiClient({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = (baseUrl == null || baseUrl.trim().isEmpty)
          ? const String.fromEnvironment(
              'JOLPI_BASE_URL',
              defaultValue: 'https://api.jolpi.ca/ergast/f1',
            )
          : baseUrl.trim();

  final http.Client _client;
  final String _baseUrl;

  /// Ejecuta una petición GET y devuelve el JSON como mapa.
  ///
  /// Lanza [ApiException] en caso de error HTTP, red, timeout o JSON inválido.
  Future<Map<String, dynamic>> getJson(
    String endpoint, {
    Map<String, String> queryParameters = const <String, String>{},
  }) async {
    return _request(_baseUrl, endpoint, queryParameters: queryParameters);
  }

  /// Implementación interna de la petición HTTP.
  Future<Map<String, dynamic>> _request(
    String baseUrl,
    String endpoint, {
    required Map<String, String> queryParameters,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint').replace(
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );

    try {
      final response = await _client
          .get(
            uri,
            headers: const <String, String>{'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        throw ApiException('Formato JSON inesperado.');
      }

      throw ApiException(
        'Error HTTP ${response.statusCode}: ${response.reasonPhrase ?? 'sin detalle'}',
      );
    } on SocketException {
      throw ApiException('Sin conexión a internet.');
    } on http.ClientException {
      throw ApiException('Error de cliente HTTP.');
    } on HttpException {
      throw ApiException('Error de red HTTP.');
    } on FormatException {
      throw ApiException('Respuesta JSON inválida.');
    } on TimeoutException {
      throw ApiException('La petición excedió el tiempo límite.');
    }
  }

  /// Libera recursos del cliente HTTP.
  void dispose() {
    _client.close();
  }
}
