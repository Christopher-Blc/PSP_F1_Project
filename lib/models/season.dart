/// Entidad de dominio para una temporada de F1.
class Season {
  /// Crea una entidad [Season].
  const Season({required this.year, this.wikiUrl});

  /// Año numérico de la temporada.
  final int year;

  /// URL de referencia de la temporada.
  final String? wikiUrl;

  /// Convierte JSON de Jolpi en una entidad [Season].
  factory Season.fromJolpiJson(Map<String, dynamic> json) {
    final year = int.tryParse((json['season'] ?? '0').toString()) ?? 0;
    return Season(year: year, wikiUrl: json['url']?.toString());
  }
}
