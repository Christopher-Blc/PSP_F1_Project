/// Entidad de dominio para un piloto de F1.
class Driver {
  /// Crea una entidad [Driver].
  const Driver({
    required this.id,
    required this.name,
    this.country,
    this.number,
    this.code,
    this.birthDate,
    this.wikiUrl,
  });

  /// Identificador único del piloto en la API.
  final String id;

  /// Nombre completo del piloto.
  final String name;

  /// Nacionalidad del piloto.
  final String? country;

  /// Número permanente de dorsal.
  final int? number;

  /// Código corto del piloto (si existe).
  final String? code;

  /// Fecha de nacimiento en formato texto.
  final String? birthDate;

  /// URL de referencia (Wikipedia u otra).
  final String? wikiUrl;

  /// Convierte JSON de Jolpi en una entidad [Driver].
  factory Driver.fromJolpiJson(Map<String, dynamic> json) {
    final givenName = json['givenName']?.toString().trim() ?? '';
    final familyName = json['familyName']?.toString().trim() ?? '';
    final fullName = '$givenName $familyName'.trim();

    return Driver(
      id: (json['driverId'] ?? 'unknown').toString(),
      name: fullName.isEmpty ? 'Sin nombre' : fullName,
      country: json['nationality']?.toString(),
      number: _parseInt(json['permanentNumber']),
      code: json['code']?.toString(),
      birthDate: json['dateOfBirth']?.toString(),
      wikiUrl: json['url']?.toString(),
    );
  }

  /// Convierte un valor dinámico en entero, si es posible.
  static int? _parseInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    return int.tryParse(value.toString());
  }
}
