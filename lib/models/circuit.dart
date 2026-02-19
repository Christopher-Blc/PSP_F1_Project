/// Entidad de dominio para un circuito.
class Circuit {
  /// Crea una entidad [Circuit].
  const Circuit({
    required this.id,
    required this.name,
    this.city,
    this.country,
    this.latitude,
    this.longitude,
    this.wikiUrl,
  });

  /// Identificador del circuito en la API.
  final String id;

  /// Nombre oficial del circuito.
  final String name;

  /// Ciudad del circuito.
  final String? city;

  /// País del circuito.
  final String? country;

  /// Latitud textual del circuito.
  final String? latitude;

  /// Longitud textual del circuito.
  final String? longitude;

  /// URL de referencia (Wikipedia u otra).
  final String? wikiUrl;

  /// Convierte JSON de Jolpi en una entidad [Circuit].
  factory Circuit.fromJolpiJson(Map<String, dynamic> json) {
    final location = json['Location'] as Map<String, dynamic>?;

    return Circuit(
      id: (json['circuitId'] ?? 'unknown').toString(),
      name: (json['circuitName'] ?? 'Sin circuito').toString(),
      city: location?['locality']?.toString(),
      country: location?['country']?.toString(),
      latitude: location?['lat']?.toString(),
      longitude: location?['long']?.toString(),
      wikiUrl: json['url']?.toString(),
    );
  }
}
