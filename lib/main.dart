import 'package:flutter/material.dart';

import 'repositories/f1_repository.dart';
import 'screens/circuits_screen.dart';
import 'screens/drivers_screen.dart';
import 'screens/home_screen.dart';
import 'screens/seasons_screen.dart';
import 'screens/teams_screen.dart';
import 'services/jolpi_api_client.dart';

/// Punto de entrada de la aplicación.
void main() {
  runApp(const AppBootstrap());
}

/// Bootstrap con control explícito del ciclo de vida de recursos.
class AppBootstrap extends StatefulWidget {
  /// Crea el bootstrap de la app.
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

/// Estado de bootstrap que crea y libera dependencias compartidas.
class _AppBootstrapState extends State<AppBootstrap> {
  late final JolpiApiClient _apiClient;
  late final F1Repository _repository;

  @override
  void initState() {
    super.initState();
    _apiClient = JolpiApiClient();
    _repository = F1Repository(_apiClient);
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MyApp(repository: _repository);
  }
}

/// Widget raíz de la aplicación Flutter.
class MyApp extends StatelessWidget {
  /// Crea la app principal.
  const MyApp({super.key, required this.repository});

  /// Repositorio compartido por las pantallas.
  final F1Repository repository;

  @override
  Widget build(BuildContext context) {
    const primaryRed = Color(0xFFE10600);
    const deepBlack = Color(0xFF0B0B0D);
    const softBlack = Color(0xFF141519);
    const cardBlack = Color(0xFF1B1D22);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'F1 2026 - Welcome to the season!',
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: primaryRed,
          onPrimary: Colors.white,
          secondary: Color(0xFF2C2F38),
          onSecondary: Color(0xFFE9E9E9),
          error: Color(0xFFFF4D4F),
          onError: Colors.white,
          surface: softBlack,
          onSurface: Color(0xFFEDEDED),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: deepBlack,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: cardBlack,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            foregroundColor: Colors.white,
            backgroundColor: primaryRed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
      home: Builder(
        builder: (context) => HomeScreen(
          onDriversTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => DriversScreen(repository: repository),
              ),
            );
          },
          onTeamsTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => TeamsScreen(repository: repository),
              ),
            );
          },
          onCircuitsTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => CircuitsScreen(repository: repository),
              ),
            );
          },
          onSeasonsTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => SeasonsScreen(repository: repository),
              ),
            );
          },
        ),
      ),
    );
  }
}
