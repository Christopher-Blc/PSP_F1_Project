/// Entidad de dominio para una escudería.
class Team {
  /// Crea una entidad [Team].
  const Team({
    required this.id,
    required this.name,
    this.country,
    this.wikiUrl,
  });

  /// Identificador único del equipo en la API.
  final String id;

  /// Nombre visible del equipo.
  final String name;

  /// Nacionalidad del equipo.
  final String? country;

  /// URL de referencia (Wikipedia u otra).
  final String? wikiUrl;

  /// Convierte JSON de Jolpi en una entidad [Team].
  factory Team.fromJolpiJson(Map<String, dynamic> json) {
    return Team(
      id: (json['constructorId'] ?? 'unknown').toString(),
      name: (json['name'] ?? 'Sin equipo').toString(),
      country: json['nationality']?.toString(),
      wikiUrl: json['url']?.toString(),
    );
  }
}
