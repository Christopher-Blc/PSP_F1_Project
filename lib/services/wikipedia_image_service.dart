import 'dart:convert';
import 'dart:core';

import 'package:http/http.dart' as http;

/// Servicio para resolver imágenes desde Wikipedia REST.
///
/// Mantiene caché en memoria para no repetir llamadas por entidad.
class WikipediaImageService {
  /// Crea el servicio de imágenes de Wikipedia.
  ///
  /// [client] permite inyección para pruebas.
  WikipediaImageService({http.Client? client})
    : _client = client ?? http.Client();

  /// Cliente HTTP usado para consultar Wikipedia.
  final http.Client _client;

  /// Caché en memoria: `id_entidad -> url_imagen`.
  final Map<String, String?> _cache = <String, String?>{};

  /// Control de llamadas en curso para evitar peticiones duplicadas.
  final Map<String, Future<String?>> _inFlight = <String, Future<String?>>{};

  /// Obtiene la URL de imagen de un piloto.
  ///
  /// [cacheKey] identifica de forma única al piloto para cachear.
  /// [fullName] se usa para construir el `title` del endpoint summary.
  Future<String?> getDriverImageUrl(
    String cacheKey,
    String fullName, {
    String? wikiUrl,
  }) async {
    return _getImageUrlWithFallback(
      cacheKey: cacheKey,
      displayName: fullName,
      wikiUrl: wikiUrl,
    );
  }

  /// Obtiene la URL de imagen de un equipo.
  ///
  /// Intenta primero usando [wikiUrl] y, si falla, usa [teamName].
  Future<String?> getTeamImageUrl(
    String cacheKey,
    String teamName, {
    String? wikiUrl,
  }) async {
    return _getImageUrlWithFallback(
      cacheKey: cacheKey,
      displayName: teamName,
      wikiUrl: wikiUrl,
    );
  }

  /// Obtiene la URL de imagen de un circuito.
  ///
  /// Intenta primero usando [wikiUrl] y, si falla, usa [circuitName].
  Future<String?> getCircuitImageUrl(
    String cacheKey,
    String circuitName, {
    String? wikiUrl,
  }) async {
    return _getImageUrlWithFallback(
      cacheKey: cacheKey,
      displayName: circuitName,
      wikiUrl: wikiUrl,
    );
  }

  Future<String?> _getImageUrlWithFallback({
    required String cacheKey,
    required String displayName,
    required String? wikiUrl,
  }) async {
    final titleFromWikiUrl = _extractWikipediaTitle(wikiUrl);

    if (titleFromWikiUrl != null && titleFromWikiUrl.isNotEmpty) {
      final fromWikiUrl = await _getImageUrl(
        cacheKey,
        titleFromWikiUrl,
        alreadyEncodedTitle: true,
      );
      if (fromWikiUrl != null && fromWikiUrl.isNotEmpty) {
        return fromWikiUrl;
      }
    }

    return _getImageUrl(cacheKey, displayName);
  }

  /// Resuelve primero desde caché y, si no existe, consulta la API.
  Future<String?> _getImageUrl(
    String cacheKey,
    String titleName, {
    bool alreadyEncodedTitle = false,
  }) {
    if (_cache.containsKey(cacheKey)) {
      return Future<String?>.value(_cache[cacheKey]);
    }

    final pending = _inFlight[cacheKey];
    if (pending != null) {
      return pending;
    }

    final future = _fetchImageUrl(
      cacheKey,
      titleName,
      alreadyEncodedTitle: alreadyEncodedTitle,
    );
    _inFlight[cacheKey] = future;
    return future;
  }

  /// Consulta Wikipedia summary para obtener una URL de imagen.
  ///
  /// Prioriza `originalimage.source` y usa `thumbnail.source` como fallback.
  Future<String?> _fetchImageUrl(
    String cacheKey,
    String titleName, {
    required bool alreadyEncodedTitle,
  }) async {
    try {
      final title = alreadyEncodedTitle
          ? titleName
          : Uri.encodeComponent(titleName.trim().replaceAll(' ', '_'));
      final uri = Uri.parse(
        'https://en.wikipedia.org/api/rest_v1/page/summary/$title',
      );

      final response = await _client.get(
        uri,
        headers: const <String, String>{'Accept': 'application/json'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final originalImage = decoded['originalimage'];
          if (originalImage is Map<String, dynamic>) {
            final source = originalImage['source']?.toString();
            if (source != null && source.isNotEmpty) {
              _cache[cacheKey] = source;
              return source;
            }
          }

          final thumbnail = decoded['thumbnail'];
          if (thumbnail is Map<String, dynamic>) {
            final source = thumbnail['source']?.toString();
            if (source != null && source.isNotEmpty) {
              _cache[cacheKey] = source;
              return source;
            }
          }
        }
      }

      _cache[cacheKey] = null;
      return null;
    } catch (_) {
      _cache[cacheKey] = null;
      return null;
    } finally {
      _inFlight.remove(cacheKey);
    }
  }

  /// Extrae el título de Wikipedia desde una URL completa.
  String? _extractWikipediaTitle(String? wikiUrl) {
    if (wikiUrl == null || wikiUrl.trim().isEmpty) {
      return null;
    }

    try {
      final uri = Uri.parse(wikiUrl);
      if (uri.pathSegments.isEmpty) {
        return null;
      }
      final lastSegment = uri.pathSegments.last;
      if (lastSegment.isEmpty) {
        return null;
      }
      return lastSegment;
    } catch (_) {
      return null;
    }
  }

  /// Libera recursos del cliente HTTP.
  void dispose() {
    _client.close();
  }
}
