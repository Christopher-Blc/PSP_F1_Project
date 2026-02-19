import '../models/circuit.dart';
import '../models/driver.dart';
import '../models/season.dart';
import '../models/team.dart';
import '../services/api_exception.dart';
import '../services/jolpi_api_client.dart';

/// Repositorio de acceso a datos de F1.
///
/// Orquesta llamadas asíncronas al cliente HTTP, transforma JSON a entidades
/// y mantiene una caché en memoria para evitar peticiones repetidas.
class F1Repository {
  /// Crea el repositorio con su cliente de API.
  F1Repository(this._apiClient);

  final JolpiApiClient _apiClient;

  List<Driver>? _driversCache;
  List<Team>? _teamsCache;
  List<Circuit>? _circuitsCache;
  List<Season>? _seasonsCache;

  /// Libera recursos del repositorio y limpia caché en memoria.
  ///
  /// Este método forma parte del control del ciclo de vida para evitar
  /// mantener clientes HTTP abiertos cuando la app se cierra.
  void dispose() {
    _driversCache = null;
    _teamsCache = null;
    _circuitsCache = null;
    _seasonsCache = null;
    _apiClient.dispose();
  }

  /// Devuelve la lista de pilotos de la temporada actual.
  ///
  /// Si [forceRefresh] es `false`, intenta reutilizar caché en memoria.
  Future<List<Driver>> getDrivers({bool forceRefresh = false}) async {
    if (!forceRefresh && _driversCache != null) {
      return _driversCache!;
    }

    final data = await _apiClient.getJson(
      '/current/drivers.json',
      queryParameters: const <String, String>{'limit': '200'},
    );

    final rawDrivers = _extractNestedList(data, const <String>[
      'MRData',
      'DriverTable',
      'Drivers',
    ]);

    if (rawDrivers.isEmpty) {
      throw ApiException(
        'No hay pilotos disponibles para la temporada actual.',
      );
    }

    final drivers = rawDrivers.map(Driver.fromJolpiJson).toList(growable: false)
      ..sort((a, b) => a.name.compareTo(b.name));

    _driversCache = drivers;
    return drivers;
  }

  /// Devuelve la lista de equipos de la temporada actual.
  ///
  /// Si [forceRefresh] es `false`, intenta reutilizar caché en memoria.
  Future<List<Team>> getTeams({bool forceRefresh = false}) async {
    if (!forceRefresh && _teamsCache != null) {
      return _teamsCache!;
    }

    final data = await _apiClient.getJson(
      '/current/constructors.json',
      queryParameters: const <String, String>{'limit': '200'},
    );

    final rawTeams = _extractNestedList(data, const <String>[
      'MRData',
      'ConstructorTable',
      'Constructors',
    ]);

    if (rawTeams.isEmpty) {
      throw ApiException(
        'No hay equipos disponibles para la temporada actual.',
      );
    }

    final teams = rawTeams.map(Team.fromJolpiJson).toList(growable: false)
      ..sort((a, b) => a.name.compareTo(b.name));

    _teamsCache = teams;
    return teams;
  }

  /// Devuelve la lista de circuitos de la temporada actual.
  ///
  /// Si [forceRefresh] es `false`, intenta reutilizar caché en memoria.
  Future<List<Circuit>> getCircuits({bool forceRefresh = false}) async {
    if (!forceRefresh && _circuitsCache != null) {
      return _circuitsCache!;
    }

    final data = await _apiClient.getJson(
      '/current/circuits.json',
      queryParameters: const <String, String>{'limit': '200'},
    );

    final rawCircuits = _extractNestedList(data, const <String>[
      'MRData',
      'CircuitTable',
      'Circuits',
    ]);

    if (rawCircuits.isEmpty) {
      throw ApiException(
        'No hay circuitos disponibles para la temporada actual.',
      );
    }

    final circuits =
        rawCircuits.map(Circuit.fromJolpiJson).toList(growable: false)
          ..sort((a, b) => a.name.compareTo(b.name));

    _circuitsCache = circuits;
    return circuits;
  }

  /// Devuelve todas las temporadas disponibles, ordenadas de nueva a antigua.
  ///
  /// Si [forceRefresh] es `false`, intenta reutilizar caché en memoria.
  Future<List<Season>> getSeasons({bool forceRefresh = false}) async {
    if (!forceRefresh && _seasonsCache != null) {
      return _seasonsCache!;
    }

    final data = await _apiClient.getJson(
      '/seasons.json',
      queryParameters: const <String, String>{'limit': '200'},
    );

    final rawSeasons = _extractNestedList(data, const <String>[
      'MRData',
      'SeasonTable',
      'Seasons',
    ]);

    if (rawSeasons.isEmpty) {
      throw ApiException('No hay temporadas disponibles.');
    }

    final seasons =
        rawSeasons
            .map(Season.fromJolpiJson)
            .where((season) => season.year > 0)
            .toList(growable: false)
          ..sort((a, b) => b.year.compareTo(a.year));

    _seasonsCache = seasons;
    return seasons;
  }

  /// Extrae una lista anidada recorriendo un path de claves.
  List<Map<String, dynamic>> _extractNestedList(
    Map<String, dynamic> source,
    List<String> path,
  ) {
    dynamic current = source;
    for (final key in path) {
      if (current is Map<String, dynamic>) {
        current = current[key];
      } else {
        return const <Map<String, dynamic>>[];
      }
    }

    if (current is List) {
      return current.whereType<Map<String, dynamic>>().toList(growable: false);
    }

    return const <Map<String, dynamic>>[];
  }
}
